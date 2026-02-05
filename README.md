# Azure Landing Zone Vending Module

This Terraform module wraps the Azure Verified Module (AVM) for Azure Landing Zone Subscription Vending to provide simplified subscription vending capabilities.

## Usage

```hcl
module "landing_zone" {
  source = "github.com/nathlan/terraform-azurerm-landing-zone-vending"

  location                         = "australiaeast"
  subscription_display_name        = "my-workload-subscription"
  subscription_alias_name          = "my-workload-sub"
  subscription_workload            = "Production"
  subscription_management_group_id = "/providers/Microsoft.Management/managementGroups/landingzones"
  
  subscription_tags = {
    Environment = "Production"
    CostCenter  = "Engineering"
  }
}
```

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
| <a name="module_landing_zone_vending"></a> [landing_zone_vending](#module_landing_zone_vending) | Azure/avm-ptn-alz-sub-vending/azure | 0.1.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_telemetry"></a> [enable_telemetry](#input_enable_telemetry) | Enable telemetry via a customer usage attribution tag. This allows Microsoft to track usage of this module. | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input_location) | The default location of resources created by this module. Virtual networks will be created in this location unless overridden. | `string` | n/a | yes |
| <a name="input_resource_group_creation_enabled"></a> [resource_group_creation_enabled](#input_resource_group_creation_enabled) | Whether to create resource groups. | `bool` | `false` | no |
| <a name="input_resource_groups"></a> [resource_groups](#input_resource_groups) | Map of resource groups to create. | <pre>map(object({<br/>    name     = string<br/>    location = optional(string)<br/>    tags     = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_role_assignment_enabled"></a> [role_assignment_enabled](#input_role_assignment_enabled) | Whether to create role assignments for the subscription. | `bool` | `false` | no |
| <a name="input_role_assignments"></a> [role_assignments](#input_role_assignments) | Map of role assignments to create for the subscription. | <pre>map(object({<br/>    principal_id                     = string<br/>    definition                       = string<br/>    relative_scope                   = string<br/>    condition                        = optional(string)<br/>    condition_version                = optional(string)<br/>    description                      = optional(string)<br/>    principal_type                   = optional(string)<br/>    skip_service_principal_aad_check = optional(bool, false)<br/>  }))</pre> | `{}` | no |
| <a name="input_subscription_alias_enabled"></a> [subscription_alias_enabled](#input_subscription_alias_enabled) | Whether to create a new subscription using the alias API. | `bool` | `false` | no |
| <a name="input_subscription_alias_name"></a> [subscription_alias_name](#input_subscription_alias_name) | The name of the subscription alias. | `string` | `null` | no |
| <a name="input_subscription_billing_scope"></a> [subscription_billing_scope](#input_subscription_billing_scope) | The billing scope to use when creating the subscription alias. Only required when subscription_alias_enabled is true. | `string` | `null` | no |
| <a name="input_subscription_display_name"></a> [subscription_display_name](#input_subscription_display_name) | The display name for the subscription. | `string` | `null` | no |
| <a name="input_subscription_management_group_association_enabled"></a> [subscription_management_group_association_enabled](#input_subscription_management_group_association_enabled) | Whether to associate the subscription with a management group. | `bool` | `false` | no |
| <a name="input_subscription_management_group_id"></a> [subscription_management_group_id](#input_subscription_management_group_id) | The management group ID to place the subscription in. | `string` | `null` | no |
| <a name="input_subscription_tags"></a> [subscription_tags](#input_subscription_tags) | Tags to apply to the subscription. | `map(string)` | `{}` | no |
| <a name="input_subscription_workload"></a> [subscription_workload](#input_subscription_workload) | The workload type for the subscription. Valid values are 'Production' and 'DevTest'. | `string` | `null` | no |
| <a name="input_virtual_network_enabled"></a> [virtual_network_enabled](#input_virtual_network_enabled) | Whether to create virtual networks. | `bool` | `false` | no |
| <a name="input_virtual_networks"></a> [virtual_networks](#input_virtual_networks) | Map of virtual networks to create. | <pre>map(object({<br/>    name                    = string<br/>    address_space           = list(string)<br/>    resource_group_key      = string<br/>    location                = optional(string)<br/>    dns_servers             = optional(list(string), [])<br/>    ddos_protection_plan_id = optional(string)<br/>    hub_network_resource_id = optional(string)<br/>    hub_peering_enabled     = optional(bool, false)<br/>    mesh_peering_enabled    = optional(bool, false)<br/>    tags                    = optional(map(string), {})<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_management_group_subscription_association_id"></a> [management_group_subscription_association_id](#output_management_group_subscription_association_id) | The ID of the management group subscription association. |
| <a name="output_resource_group_resource_ids"></a> [resource_group_resource_ids](#output_resource_group_resource_ids) | Map of resource group names to their resource IDs. |
| <a name="output_route_table_resource_ids"></a> [route_table_resource_ids](#output_route_table_resource_ids) | Map of route table names to their resource IDs. |
| <a name="output_subscription_id"></a> [subscription_id](#output_subscription_id) | The ID of the subscription. |
| <a name="output_subscription_resource_id"></a> [subscription_resource_id](#output_subscription_resource_id) | The resource ID of the subscription. |
| <a name="output_virtual_network_resource_ids"></a> [virtual_network_resource_ids](#output_virtual_network_resource_ids) | Map of virtual network names to their resource IDs. |
<!-- END_TF_DOCS -->
