# Landing Zone Vending Module v3.0.0
# Azure Naming Integration, Time Provider, and Smart Defaults

# ========================================
# Resource Abbreviations (Internal)
# ========================================
# These abbreviations are for resource types NOT in the Azure naming module.
# Platform team can update these centrally without breaking user configurations.
# NOT exposed via variables - internal to module only.

locals {
  resource_abbreviations = {
    subscription = "sub"
    budget       = "budget"
  }
}

# ========================================
# Azure Naming Module Integration
# ========================================

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.4.3"

  for_each = var.landing_zones
  suffix   = [each.value.workload, each.value.env]
}

# Separate naming instances for resource groups with purpose prefix
module "naming_rg_identity" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.4.3"

  for_each = var.landing_zones
  suffix   = ["identity", each.value.workload, each.value.env]
}

module "naming_rg_network" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.4.3"

  for_each = var.landing_zones
  suffix   = ["network", each.value.workload, each.value.env]
}

# ========================================
# Time Provider for Budget Timestamps
# ========================================

resource "time_static" "budget" {
  for_each = {
    for lz_key, lz in var.landing_zones :
    lz_key => lz
    if lz.budgets != null
  }
}

resource "time_offset" "budget_end" {
  for_each = {
    for lz_key, lz in var.landing_zones :
    lz_key => lz
    if lz.budgets != null
  }

  base_rfc3339  = time_static.budget[each.key].rfc3339
  offset_months = 12
}

# ========================================
# IP Address Automation
# ========================================

# Calculate prefix sizes for VNets from landing zones
locals {
  vnet_prefix_sizes = {
    for lz_key, lz in var.landing_zones :
    lz_key => tonumber(trimprefix(lz.address_space_required, "/"))
    if lz.address_space_required != null
  }
}

module "ip_addresses" {
  count = length(local.vnet_prefix_sizes) > 0 ? 1 : 0

  source  = "Azure/avm-utl-network-ip-addresses/azurerm"
  version = "~> 0.1.0"

  address_space                 = var.base_address_space
  address_prefixes              = local.vnet_prefix_sizes
  address_prefix_efficient_mode = true
  enable_telemetry              = var.enable_telemetry
}

# ========================================
# Locals for Resource Configuration
# ========================================

locals {
  # Subscription names
  subscription_names = {
    for lz_key, lz in var.landing_zones :
    lz_key => "${local.resource_abbreviations.subscription}-${lz.workload}-${lz.env}"
  }

  # Tag merging: Common + Auto-generated + Custom
  merged_tags = {
    for lz_key, lz in var.landing_zones :
    lz_key => merge(
      var.tags,
      {
        env      = lz.env
        workload = lz.workload
        owner    = lz.team
      },
      lz.subscription_tags
    )
  }

  # Virtual network configurations with calculated address spaces
  virtual_networks = {
    for lz_key, lz in var.landing_zones :
    lz_key => lz.address_space_required != null ? {
      name                    = module.naming[lz_key].virtual_network.name
      resource_group_key      = "rg_network"
      location                = lz.location
      address_space           = length(local.vnet_prefix_sizes) > 0 ? [module.ip_addresses[0].address_prefixes[lz_key]] : []
      dns_servers             = lz.dns_servers
      hub_network_resource_id = var.hub_network_resource_id
      hub_peering_enabled     = var.hub_network_resource_id != null ? lz.hub_peering_enabled : false
      mesh_peering_enabled    = false
      tags                    = local.merged_tags[lz_key]
      # Subnets will be added by AVM module
    } : null
    if lz.address_space_required != null
  }
}

# ========================================
# Azure Landing Zone Vending Module
# ========================================

module "landing_zone_vending" {
  source  = "Azure/avm-ptn-alz-sub-vending/azure"
  version = "~> 0.1.0"

  for_each = var.landing_zones
  location = each.value.location

  # ========================================
  # Subscription Configuration
  # ========================================

  subscription_alias_enabled                        = true
  subscription_billing_scope                        = var.subscription_billing_scope
  subscription_display_name                         = local.subscription_names[each.key]
  subscription_alias_name                           = local.subscription_names[each.key]
  subscription_workload                             = each.value.subscription_devtest_enabled ? "DevTest" : "Production"
  subscription_management_group_id                  = var.subscription_management_group_id
  subscription_management_group_association_enabled = true
  subscription_tags                                 = local.merged_tags[each.key]

  # ========================================
  # Resource Groups (Always Created)
  # ========================================

  resource_group_creation_enabled = true
  resource_groups = {
    rg_identity = {
      name     = module.naming_rg_identity[each.key].resource_group.name
      location = each.value.location
      tags     = local.merged_tags[each.key]
    }
    rg_network = {
      name     = module.naming_rg_network[each.key].resource_group.name
      location = each.value.location
      tags     = local.merged_tags[each.key]
    }
  }

  # ========================================
  # Virtual Networks (Conditional)
  # ========================================

  virtual_network_enabled = each.value.address_space_required != null
  virtual_networks = each.value.address_space_required != null ? {
    spoke = local.virtual_networks[each.key]
  } : {}

  # ========================================
  # User-Managed Identities (Always Created)
  # ========================================

  umi_enabled = true
  user_managed_identities = {
    plan = {
      name               = "${module.naming[each.key].user_assigned_identity.name}-plan"
      resource_group_key = "rg_identity"
      location           = each.value.location
      tags               = local.merged_tags[each.key]

      role_assignments = {
        subscription_reader = {
          definition     = "Reader"
          relative_scope = ""
        }
      }

      federated_credentials_github = each.value.federated_credentials_github != null ? {
        plan = {
          organization = var.github_organization
          repository   = each.value.federated_credentials_github.repository
          entity       = "pull_request"
          value        = ""
        }
      } : {}
    }

    deploy = {
      name               = "${module.naming[each.key].user_assigned_identity.name}-deploy"
      resource_group_key = "rg_identity"
      location           = each.value.location
      tags               = local.merged_tags[each.key]

      role_assignments = {
        subscription_owner = {
          definition     = "Owner"
          relative_scope = ""
        }
      }

      federated_credentials_github = each.value.federated_credentials_github != null ? {
        deploy = {
          organization = var.github_organization
          repository   = each.value.federated_credentials_github.repository
          entity       = "branch"
          value        = "main"
        }
      } : {}
    }
  }

  # ========================================
  # Budgets (Conditional)
  # ========================================

  budget_enabled = each.value.budgets != null
  budgets = each.value.budgets != null ? {
    monthly = {
      name              = "${local.resource_abbreviations.budget}-${each.value.workload}-${each.value.env}"
      amount            = each.value.budgets.amount
      time_grain        = "Monthly"
      time_period_start = time_static.budget[each.key].rfc3339
      time_period_end   = time_offset.budget_end[each.key].rfc3339
      relative_scope    = ""

      notifications = {
        threshold = {
          enabled        = true
          operator       = "GreaterThan"
          threshold      = each.value.budgets.threshold
          threshold_type = "Actual"
          contact_emails = each.value.budgets.contact_emails
          contact_roles  = []
          contact_groups = []
          locale         = "en-us"
        }
      }
    }
  } : {}

  # ========================================
  # Role Assignments (None by Default)
  # ========================================

  role_assignment_enabled = false
  role_assignments        = {}

  # ========================================
  # Telemetry
  # ========================================

  enable_telemetry = var.enable_telemetry
}
