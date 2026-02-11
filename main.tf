# Landing Zone Vending Module
# Wraps Azure Verified Module for ALZ Subscription Vending

# Automatically calculate address spaces for virtual networks if ip_address_automation is enabled
module "ip_addresses" {
  count = var.ip_address_automation_enabled ? 1 : 0

  source  = "Azure/avm-utl-network-ip-addresses/azurerm"
  version = "~> 0.1.0"

  address_space                 = var.ip_address_automation_address_space
  address_prefixes              = var.ip_address_automation_vnet_prefix_sizes
  address_prefix_efficient_mode = true
  enable_telemetry              = var.enable_telemetry
}

# Create a local map of virtual networks with calculated or provided address spaces
locals {
  # When IP automation is enabled, merge calculated addresses into virtual networks
  virtual_networks_with_addresses = var.ip_address_automation_enabled ? {
    for key, vnet in var.virtual_networks : key => merge(
      vnet,
      {
        # Use calculated address space if not explicitly provided
        address_space = vnet.address_space != null ? vnet.address_space : (
          contains(keys(module.ip_addresses[0].address_prefixes), key) ?
          [module.ip_addresses[0].address_prefixes[key]] : []
        )
      }
    )
  } : var.virtual_networks
}

module "landing_zone_vending" {
  source  = "Azure/avm-ptn-alz-sub-vending/azure"
  version = "0.1.0"

  # Required location
  location = var.location

  # Subscription configuration
  subscription_alias_enabled                        = var.subscription_alias_enabled
  subscription_billing_scope                        = var.subscription_billing_scope
  subscription_display_name                         = var.subscription_display_name
  subscription_alias_name                           = var.subscription_alias_name
  subscription_workload                             = var.subscription_workload
  subscription_management_group_id                  = var.subscription_management_group_id
  subscription_management_group_association_enabled = var.subscription_management_group_association_enabled
  subscription_tags                                 = var.subscription_tags

  # Resource groups
  resource_group_creation_enabled = var.resource_group_creation_enabled
  resource_groups                 = var.resource_groups

  # Role assignments
  role_assignment_enabled = var.role_assignment_enabled
  role_assignments        = var.role_assignments

  # Virtual networks - use address spaces from automation or direct input
  virtual_network_enabled = var.virtual_network_enabled
  virtual_networks        = local.virtual_networks_with_addresses

  # User-Managed Identities
  umi_enabled             = var.umi_enabled
  user_managed_identities = var.user_managed_identities

  # Budgets
  budget_enabled = var.budget_enabled
  budgets        = var.budgets

  # Telemetry
  enable_telemetry = var.enable_telemetry
}
