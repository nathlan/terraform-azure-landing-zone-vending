# Terraform Azure Landing Zone Vending Module

Private wrapper module for Azure Verified Module (AVM) subscription vending pattern. Provides a simplified interface for creating Azure Landing Zone subscriptions with management group association, networking, user-managed identities, budgets, and automatic IP address space allocation.

## Features

- **Automatic IP Address Allocation**: Optionally calculate IP address spaces automatically from a base address range
- **Subscription Vending**: Create and manage Azure subscriptions with management group associations
- **Virtual Networking**: Deploy spoke VNets with hub peering and mesh connectivity
- **Identity Management**: Create user-managed identities with OIDC federated credentials
- **Budget Management**: Set up cost budgets with notifications

## Usage

### Basic Example (Manual Address Spaces)

```hcl
module "landing_zone" {
  source = "github.com/nathlan/terraform-azurerm-landing-zone-vending"

  location                                          = "australiaeast"
  subscription_alias_enabled                        = true
  subscription_billing_scope                        = "/providers/Microsoft.Billing/billingAccounts/..."
  subscription_display_name                         = "My Corp Landing Zone"
  subscription_alias_name                           = "sub-corp-prod"
  subscription_workload                             = "Production"
  subscription_management_group_id                  = "Corp"
  subscription_management_group_association_enabled = true

  virtual_network_enabled = true
  virtual_networks = {
    spoke1 = {
      name                    = "vnet-corp-prod-australiaeast"
      address_space           = ["10.100.0.0/24"]
      resource_group_key      = "network"
      hub_network_resource_id = "/subscriptions/.../resourceGroups/.../providers/Microsoft.Network/virtualNetworks/..."
      hub_peering_enabled     = true
    }
  }
}
```

### Automatic IP Address Allocation Example

When managing multiple landing zones in a single Terraform state, use automatic IP address allocation to prevent conflicts:

```hcl
module "landing_zones" {
  source = "github.com/nathlan/terraform-azurerm-landing-zone-vending"
  
  for_each = {
    workload1 = { display_name = "Workload 1", mgmt_group = "Corp" }
    workload2 = { display_name = "Workload 2", mgmt_group = "Online" }
    workload3 = { display_name = "Workload 3", mgmt_group = "Corp" }
  }

  location                                          = "australiaeast"
  subscription_alias_enabled                        = true
  subscription_billing_scope                        = var.billing_scope
  subscription_display_name                         = each.value.display_name
  subscription_alias_name                           = "sub-${each.key}"
  subscription_workload                             = "Production"
  subscription_management_group_id                  = each.value.mgmt_group
  subscription_management_group_association_enabled = true

  # Enable automatic IP address allocation
  ip_address_automation_enabled      = true
  ip_address_automation_address_space = "10.100.0.0/16"  # Base address space for all spokes
  ip_address_automation_vnet_prefix_sizes = {
    spoke1 = 24  # Allocate /24 (256 addresses) for spoke1
  }

  virtual_network_enabled = true
  virtual_networks = {
    spoke1 = {
      name               = "vnet-${each.key}-prod-australiaeast"
      # address_space is optional when automation is enabled - will be calculated automatically
      resource_group_key = "network"
      hub_network_resource_id = var.hub_network_resource_id
      hub_peering_enabled     = true
    }
  }
}

# Output the calculated address spaces
output "calculated_address_spaces" {
  value = {
    for key, lz in module.landing_zones : key => lz.virtual_networks_address_spaces
  }
}
```

The IP address automation will efficiently allocate non-overlapping address spaces from the base range (10.100.0.0/16) to each landing zone's VNet.

### Mixed Mode (Some Automatic, Some Manual)

You can also mix automatic and manual address space allocation:

```hcl
module "landing_zone" {
  source = "github.com/nathlan/terraform-azurerm-landing-zone-vending"

  location = "australiaeast"
  # ... subscription config ...

  # Enable IP automation
  ip_address_automation_enabled      = true
  ip_address_automation_address_space = "10.100.0.0/16"
  ip_address_automation_vnet_prefix_sizes = {
    spoke1 = 24  # Auto-calculate for spoke1
    spoke2 = 25  # Auto-calculate for spoke2
  }

  virtual_network_enabled = true
  virtual_networks = {
    spoke1 = {
      name               = "vnet-spoke1"
      # address_space will be auto-calculated as 10.100.0.0/24
      resource_group_key = "network"
    }
    spoke2 = {
      name               = "vnet-spoke2"
      # address_space will be auto-calculated as 10.100.1.0/25
      resource_group_key = "network"
    }
    spoke3 = {
      name               = "vnet-spoke3"
      address_space      = ["192.168.0.0/24"]  # Explicitly provided - automation ignored
      resource_group_key = "network"
    }
  }
}
```

## IP Address Automation Details

The automatic IP address allocation feature uses the Azure Verified Module `Azure/avm-utl-network-ip-addresses/azurerm` to calculate non-overlapping address spaces efficiently. This is particularly useful when:

- Managing multiple landing zones in a single Terraform state
- All landing zones need spoke VNets from the same address range
- You want to prevent manual IP address conflicts
- Address spaces should be allocated efficiently without gaps

**How it works:**

1. Set `ip_address_automation_enabled = true`
2. Provide a base `ip_address_automation_address_space` (e.g., "10.100.0.0/16")
3. Define `ip_address_automation_vnet_prefix_sizes` with VNet keys and their desired CIDR prefix lengths
4. In `virtual_networks`, omit `address_space` for VNets that should be auto-calculated
5. The module calculates optimal non-overlapping address spaces from the base range

**Outputs:**

- `calculated_address_prefixes`: Map of calculated CIDR ranges
- `virtual_networks_address_spaces`: Final address spaces for all VNets (calculated or explicit)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.9 |
| <a name="requirement_azapi"></a> [azapi](#requirement_azapi) | >= 2.0, < 3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm) | >= 4.0, < 5.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ip_addresses"></a> [ip\_addresses](#module\_ip\_addresses) | Azure/avm-utl-network-ip-addresses/azurerm | ~> 0.1.0 |
| <a name="module_landing_zone_vending"></a> [landing\_zone\_vending](#module\_landing\_zone\_vending) | Azure/avm-ptn-alz-sub-vending/azure | 0.1.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_budget_enabled"></a> [budget\_enabled](#input\_budget\_enabled) | Whether to create budgets. If enabled, supply the list of budgets in var.budgets. | `bool` | `false` | no |
| <a name="input_budgets"></a> [budgets](#input\_budgets) | Map of budgets to create for the subscription.<br/><br/>Required fields:<br/>- name: The name of the budget<br/>- amount: The total amount of cost to track with the budget<br/>- time_grain: The time grain for the budget (Annually, BillingAnnual, BillingMonth, BillingQuarter, Monthly, or Quarterly)<br/>- time_period_start: The start date for the budget (RFC3339 format, e.g. 2024-01-01T00:00:00Z)<br/>- time_period_end: The end date for the budget (RFC3339 format)<br/><br/>Optional fields:<br/>- relative_scope: Scope relative to the created subscription (empty for subscription scope)<br/>- resource_group_key: Key of the resource group (if created in this module)<br/>- notifications: Map of notifications with:<br/>  - enabled: Whether the notification is enabled<br/>  - operator: The operator (GreaterThan or GreaterThanOrEqualTo)<br/>  - threshold: The threshold (0-1000)<br/>  - threshold_type: Actual or Forecasted<br/>  - contact_emails: List of contact emails<br/>  - contact_roles: List of contact roles<br/>  - contact_groups: List of contact groups<br/>  - locale: The locale (e.g. en-us) | <pre>map(object({<br/>    name               = string<br/>    amount             = number<br/>    time_grain         = string<br/>    time_period_start  = string<br/>    time_period_end    = string<br/>    relative_scope     = optional(string, "")<br/>    resource_group_key = optional(string)<br/>    notifications = optional(map(object({<br/>      enabled        = bool<br/>      operator       = string<br/>      threshold      = number<br/>      threshold_type = optional(string, "Actual")<br/>      contact_emails = optional(list(string), [])<br/>      contact_roles  = optional(list(string), [])<br/>      contact_groups = optional(list(string), [])<br/>      locale         = optional(string, "en-us")<br/>    })), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry) | Enable telemetry via a customer usage attribution tag. This allows Microsoft to track usage of this module. | `bool` | `true` | no |
| <a name="input_ip_address_automation_address_space"></a> [ip\_address\_automation\_address\_space](#input\_ip\_address\_automation\_address\_space) | The base address space to use for automatic IP address calculation in CIDR notation (e.g., '10.100.0.0/16'). Only used when ip_address_automation_enabled is true. | `string` | `null` | no |
| <a name="input_ip_address_automation_enabled"></a> [ip\_address\_automation\_enabled](#input\_ip\_address\_automation\_enabled) | Enable automatic IP address space calculation for virtual networks. When enabled, address spaces will be automatically calculated from the base address space unless explicitly provided in virtual_networks. | `bool` | `false` | no |
| <a name="input_ip_address_automation_vnet_prefix_sizes"></a> [ip\_address\_automation\_vnet\_prefix\_sizes](#input\_ip\_address\_automation\_vnet\_prefix\_sizes) | Map of virtual network keys to their desired prefix sizes for automatic IP address calculation.<br/>The keys must match the keys in var.virtual_networks. The values are the CIDR prefix lengths (e.g., 24 for /24).<br/>Only used when ip_address_automation_enabled is true.<br/><br/>Example:<br/>{<br/>  "vnet1" = 24  # /24 = 256 addresses<br/>  "vnet2" = 26  # /26 = 64 addresses<br/>  "vnet3" = 25  # /25 = 128 addresses<br/>} | `map(number)` | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | The default location of resources created by this module. Virtual networks will be created in this location unless overridden. | `string` | n/a | yes |
| <a name="input_resource_group_creation_enabled"></a> [resource\_group\_creation\_enabled](#input\_resource\_group\_creation\_enabled) | Whether to create resource groups. | `bool` | `false` | no |
| <a name="input_resource_groups"></a> [resource\_groups](#input\_resource\_groups) | Map of resource groups to create. | <pre>map(object({<br/>    name     = string<br/>    location = optional(string)<br/>    tags     = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_role_assignment_enabled"></a> [role\_assignment\_enabled](#input\_role\_assignment\_enabled) | Whether to create role assignments for the subscription. | `bool` | `false` | no |
| <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments) | Map of role assignments to create for the subscription. | <pre>map(object({<br/>    principal_id                     = string<br/>    definition                       = string<br/>    relative_scope                   = string<br/>    condition                        = optional(string)<br/>    condition_version                = optional(string)<br/>    description                      = optional(string)<br/>    principal_type                   = optional(string)<br/>    skip_service_principal_aad_check = optional(bool, false)<br/>  }))</pre> | `{}` | no |
| <a name="input_subscription_alias_enabled"></a> [subscription\_alias\_enabled](#input\_subscription\_alias\_enabled) | Whether to create a new subscription using the alias API. | `bool` | `false` | no |
| <a name="input_subscription_alias_name"></a> [subscription\_alias\_name](#input\_subscription\_alias\_name) | The name of the subscription alias. | `string` | `null` | no |
| <a name="input_subscription_billing_scope"></a> [subscription\_billing\_scope](#input\_subscription\_billing\_scope) | The billing scope to use when creating the subscription alias. Only required when subscription_alias_enabled is true. | `string` | `null` | no |
| <a name="input_subscription_display_name"></a> [subscription\_display\_name](#input\_subscription\_display\_name) | The display name for the subscription. | `string` | `null` | no |
| <a name="input_subscription_management_group_association_enabled"></a> [subscription\_management\_group\_association\_enabled](#input\_subscription\_management\_group\_association\_enabled) | Whether to associate the subscription with a management group. | `bool` | `false` | no |
| <a name="input_subscription_management_group_id"></a> [subscription\_management\_group\_id](#input\_subscription\_management\_group\_id) | The management group ID to place the subscription in. | `string` | `null` | no |
| <a name="input_subscription_tags"></a> [subscription\_tags](#input\_subscription\_tags) | Tags to apply to the subscription. | `map(string)` | `{}` | no |
| <a name="input_subscription_workload"></a> [subscription\_workload](#input\_subscription\_workload) | The workload type for the subscription. Valid values are 'Production' and 'DevTest'. | `string` | `null` | no |
| <a name="input_umi_enabled"></a> [umi\_enabled](#input\_umi\_enabled) | Whether to enable the creation of user-assigned managed identities. Requires user_managed_identities to be configured. | `bool` | `false` | no |
| <a name="input_user_managed_identities"></a> [user\_managed\_identities](#input\_user\_managed\_identities) | Map of user-managed identities to create. The map key must be known at plan time.<br/><br/>Required fields:<br/>- name: The name of the user-assigned managed identity<br/>- One of resource_group_key (for RGs created in this module) or resource_group_name_existing (for existing RGs)<br/><br/>Optional fields:<br/>- location: Location of the identity (defaults to module location)<br/>- tags: Tags to apply to the identity<br/>- role_assignments: Role assignments for the identity<br/>- federated_credentials_github: GitHub OIDC federated credentials<br/>- federated_credentials_terraform_cloud: Terraform Cloud federated credentials<br/>- federated_credentials_advanced: Advanced federated credentials configuration | <pre>map(object({<br/>    name                         = string<br/>    resource_group_key           = optional(string)<br/>    resource_group_name_existing = optional(string)<br/>    location                     = optional(string)<br/>    tags                         = optional(map(string), {})<br/>    role_assignments = optional(map(object({<br/>      definition                = string<br/>      relative_scope            = optional(string, "")<br/>      resource_group_scope_key  = optional(string)<br/>      condition                 = optional(string)<br/>      condition_version         = optional(string)<br/>      principal_type            = optional(string)<br/>      definition_lookup_enabled = optional(bool, false)<br/>      use_random_uuid           = optional(bool, false)<br/>    })), {})<br/>    federated_credentials_github = optional(map(object({<br/>      name            = optional(string)<br/>      organization    = string<br/>      repository      = string<br/>      entity          = string<br/>      enterprise_slug = optional(string)<br/>      value           = optional(string)<br/>    })), {})<br/>    federated_credentials_terraform_cloud = optional(map(object({<br/>      name         = optional(string)<br/>      organization = string<br/>      project      = string<br/>      workspace    = string<br/>      run_phase    = string<br/>    })), {})<br/>    federated_credentials_advanced = optional(map(object({<br/>      name               = string<br/>      subject_identifier = string<br/>      issuer_url         = string<br/>      audiences          = optional(set(string), ["api://AzureADTokenExchange"])<br/>    })), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_virtual_network_enabled"></a> [virtual\_network\_enabled](#input\_virtual\_network\_enabled) | Whether to create virtual networks. | `bool` | `false` | no |
| <a name="input_virtual_networks"></a> [virtual\_networks](#input\_virtual\_networks) | Map of virtual networks to create.<br/><br/>When ip_address_automation_enabled is true:<br/>- address_space is optional and will be automatically calculated if not provided<br/>- The map keys must match the keys in var.ip_address_automation_vnet_prefix_sizes for automatic calculation<br/><br/>When ip_address_automation_enabled is false:<br/>- address_space is required | <pre>map(object({<br/>    name                    = string<br/>    address_space           = optional(list(string))<br/>    resource_group_key      = string<br/>    location                = optional(string)<br/>    dns_servers             = optional(list(string), [])<br/>    ddos_protection_plan_id = optional(string)<br/>    hub_network_resource_id = optional(string)<br/>    hub_peering_enabled     = optional(bool, false)<br/>    mesh_peering_enabled    = optional(bool, false)<br/>    tags                    = optional(map(string), {})<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_budget_resource_ids"></a> [budget\_resource\_ids](#output\_budget\_resource\_ids) | The created budget resource IDs, expressed as a map. |
| <a name="output_calculated_address_prefixes"></a> [calculated\_address\_prefixes](#output\_calculated\_address\_prefixes) | The automatically calculated address prefixes for virtual networks when ip_address_automation_enabled is true. Returns null if automation is disabled. |
| <a name="output_calculated_address_prefixes_with_details"></a> [calculated\_address\_prefixes\_with\_details](#output\_calculated\_address\_prefixes\_with\_details) | The automatically calculated address prefixes with details when ip_address_automation_enabled is true. Returns null if automation is disabled. |
| <a name="output_management_group_subscription_association_id"></a> [management\_group\_subscription\_association\_id](#output\_management\_group\_subscription\_association\_id) | The ID of the management group subscription association. |
| <a name="output_resource_group_resource_ids"></a> [resource\_group\_resource\_ids](#output\_resource\_group\_resource\_ids) | Map of resource group names to their resource IDs. |
| <a name="output_route_table_resource_ids"></a> [route\_table\_resource\_ids](#output\_route\_table\_resource\_ids) | Map of route table names to their resource IDs. |
| <a name="output_subscription_id"></a> [subscription\_id](#output\_subscription\_id) | The ID of the subscription. |
| <a name="output_subscription_resource_id"></a> [subscription\_resource\_id](#output\_subscription\_resource\_id) | The resource ID of the subscription. |
| <a name="output_umi_client_ids"></a> [umi\_client\_ids](#output\_umi\_client\_ids) | The client IDs of the user-managed identities. Value will be null if var.umi_enabled is false. |
| <a name="output_umi_principal_ids"></a> [umi\_principal\_ids](#output\_umi\_principal\_ids) | The principal IDs (object IDs) of the user-managed identities. Value will be null if var.umi_enabled is false. |
| <a name="output_umi_resource_ids"></a> [umi\_resource\_ids](#output\_umi\_resource\_ids) | The Azure resource IDs of the user-managed identities. Value will be null if var.umi_enabled is false. |
| <a name="output_umi_tenant_ids"></a> [umi\_tenant\_ids](#output\_umi\_tenant\_ids) | The tenant IDs of the user-managed identities. Value will be null if var.umi_enabled is false. |
| <a name="output_virtual_network_resource_ids"></a> [virtual\_network\_resource\_ids](#output\_virtual\_network\_resource\_ids) | Map of virtual network names to their resource IDs. |
| <a name="output_virtual_networks_address_spaces"></a> [virtual\_networks\_address\_spaces](#output\_virtual\_networks\_address\_spaces) | Map of virtual network keys to their final address spaces (either calculated or explicitly provided). |
<!-- END_TF_DOCS -->
