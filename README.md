# Terraform Azure Landing Zone Vending Module

Private wrapper module for Azure Verified Module (AVM) subscription vending pattern. Provides a simplified interface for creating Azure Landing Zone subscriptions with management group association, networking, user-managed identities, and budgets.

## Usage

```hcl
module "landing_zone" {
  source = "github.com/nathlan/terraform-azurerm-landing-zone-vending"

  location                                          = "uksouth"
  subscription_alias_enabled                        = true
  subscription_billing_scope                        = "/providers/Microsoft.Billing/billingAccounts/..."
  subscription_display_name                         = "My Corp Landing Zone"
  subscription_alias_name                           = "sub-corp-prod"
  subscription_workload                             = "Production"
  subscription_management_group_id                  = "Corp"
  subscription_management_group_association_enabled = true

  virtual_network_enabled = true
  virtual_networks = {
    vnet1 = {
      name                    = "vnet-corp-prod-uksouth"
      address_space           = ["10.100.0.0/24"]
      resource_group_key      = "network"
      hub_network_resource_id = "/subscriptions/.../resourceGroups/.../providers/Microsoft.Network/virtualNetworks/..."
      hub_peering_enabled     = true
    }
  }

  umi_enabled = true
  user_managed_identities = {
    deploy = {
      name               = "umi-deploy"
      resource_group_key = "identity"
      federated_credentials_github = {
        main = {
          organization = "myorg"
          repository   = "myrepo"
          entity       = "ref:refs/heads/main"
        }
      }
    }
  }

  budget_enabled = true
  budgets = {
    monthly = {
      name              = "Monthly Budget"
      amount            = 500
      time_grain        = "Monthly"
      time_period_start = "2024-01-01T00:00:00Z"
      time_period_end   = "2027-12-31T23:59:59Z"
      notifications = {
        threshold_80 = {
          enabled   = true
          operator  = "GreaterThan"
          threshold = 80
        }
      }
    }
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
| <a name="input_budget_enabled"></a> [budget_enabled](#input_budget_enabled) | Whether to create budgets. If enabled, supply the list of budgets in var.budgets. | `bool` | `false` | no |
| <a name="input_budgets"></a> [budgets](#input_budgets) | Map of budgets to create for the subscription.<br/><br/>Required fields:<br/>- name: The name of the budget<br/>- amount: The total amount of cost to track with the budget<br/>- time_grain: The time grain for the budget (Annually, BillingAnnual, BillingMonth, BillingQuarter, Monthly, or Quarterly)<br/>- time_period_start: The start date for the budget (RFC3339 format, e.g. 2024-01-01T00:00:00Z)<br/>- time_period_end: The end date for the budget (RFC3339 format)<br/><br/>Optional fields:<br/>- relative_scope: Scope relative to the created subscription (empty for subscription scope)<br/>- resource_group_key: Key of the resource group (if created in this module)<br/>- notifications: Map of notifications with:<br/>  - enabled: Whether the notification is enabled<br/>  - operator: The operator (GreaterThan or GreaterThanOrEqualTo)<br/>  - threshold: The threshold (0-1000)<br/>  - threshold_type: Actual or Forecasted<br/>  - contact_emails: List of contact emails<br/>  - contact_roles: List of contact roles<br/>  - contact_groups: List of contact groups<br/>  - locale: The locale (e.g. en-us) | <pre>map(object({<br/>    name               = string<br/>    amount             = number<br/>    time_grain         = string<br/>    time_period_start  = string<br/>    time_period_end    = string<br/>    relative_scope     = optional(string, "")<br/>    resource_group_key = optional(string)<br/>    notifications = optional(map(object({<br/>      enabled        = bool<br/>      operator       = string<br/>      threshold      = number<br/>      threshold_type = optional(string, "Actual")<br/>      contact_emails = optional(list(string), [])<br/>      contact_roles  = optional(list(string), [])<br/>      contact_groups = optional(list(string), [])<br/>      locale         = optional(string, "en-us")<br/>    })), {})<br/>  }))</pre> | `{}` | no |
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
| <a name="input_umi_enabled"></a> [umi_enabled](#input_umi_enabled) | Whether to enable the creation of user-assigned managed identities. Requires user_managed_identities to be configured. | `bool` | `false` | no |
| <a name="input_user_managed_identities"></a> [user_managed_identities](#input_user_managed_identities) | Map of user-managed identities to create. The map key must be known at plan time.<br/><br/>Required fields:<br/>- name: The name of the user-assigned managed identity<br/>- One of resource_group_key (for RGs created in this module) or resource_group_name_existing (for existing RGs)<br/><br/>Optional fields:<br/>- location: Location of the identity (defaults to module location)<br/>- tags: Tags to apply to the identity<br/>- role_assignments: Role assignments for the identity<br/>- federated_credentials_github: GitHub OIDC federated credentials<br/>- federated_credentials_terraform_cloud: Terraform Cloud federated credentials<br/>- federated_credentials_advanced: Advanced federated credentials configuration | <pre>map(object({<br/>    name                         = string<br/>    resource_group_key           = optional(string)<br/>    resource_group_name_existing = optional(string)<br/>    location                     = optional(string)<br/>    tags                         = optional(map(string), {})<br/>    role_assignments = optional(map(object({<br/>      definition                = string<br/>      relative_scope            = optional(string, "")<br/>      resource_group_scope_key  = optional(string)<br/>      condition                 = optional(string)<br/>      condition_version         = optional(string)<br/>      principal_type            = optional(string)<br/>      definition_lookup_enabled = optional(bool, false)<br/>      use_random_uuid           = optional(bool, false)<br/>    })), {})<br/>    federated_credentials_github = optional(map(object({<br/>      name            = optional(string)<br/>      organization    = string<br/>      repository      = string<br/>      entity          = string<br/>      enterprise_slug = optional(string)<br/>      value           = optional(string)<br/>    })), {})<br/>    federated_credentials_terraform_cloud = optional(map(object({<br/>      name         = optional(string)<br/>      organization = string<br/>      project      = string<br/>      workspace    = string<br/>      run_phase    = string<br/>    })), {})<br/>    federated_credentials_advanced = optional(map(object({<br/>      name               = string<br/>      subject_identifier = string<br/>      issuer_url         = string<br/>      audiences          = optional(set(string), ["api://AzureADTokenExchange"])<br/>    })), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_virtual_network_enabled"></a> [virtual_network_enabled](#input_virtual_network_enabled) | Whether to create virtual networks. | `bool` | `false` | no |
| <a name="input_virtual_networks"></a> [virtual_networks](#input_virtual_networks) | Map of virtual networks to create. | <pre>map(object({<br/>    name                    = string<br/>    address_space           = list(string)<br/>    resource_group_key      = string<br/>    location                = optional(string)<br/>    dns_servers             = optional(list(string), [])<br/>    ddos_protection_plan_id = optional(string)<br/>    hub_network_resource_id = optional(string)<br/>    hub_peering_enabled     = optional(bool, false)<br/>    mesh_peering_enabled    = optional(bool, false)<br/>    tags                    = optional(map(string), {})<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_budget_resource_ids"></a> [budget_resource_ids](#output_budget_resource_ids) | The created budget resource IDs, expressed as a map. |
| <a name="output_management_group_subscription_association_id"></a> [management_group_subscription_association_id](#output_management_group_subscription_association_id) | The ID of the management group subscription association. |
| <a name="output_resource_group_resource_ids"></a> [resource_group_resource_ids](#output_resource_group_resource_ids) | Map of resource group names to their resource IDs. |
| <a name="output_route_table_resource_ids"></a> [route_table_resource_ids](#output_route_table_resource_ids) | Map of route table names to their resource IDs. |
| <a name="output_subscription_id"></a> [subscription_id](#output_subscription_id) | The ID of the subscription. |
| <a name="output_subscription_resource_id"></a> [subscription_resource_id](#output_subscription_resource_id) | The resource ID of the subscription. |
| <a name="output_umi_client_ids"></a> [umi_client_ids](#output_umi_client_ids) | The client IDs of the user-managed identities. Value will be null if var.umi_enabled is false. |
| <a name="output_umi_principal_ids"></a> [umi_principal_ids](#output_umi_principal_ids) | The principal IDs (object IDs) of the user-managed identities. Value will be null if var.umi_enabled is false. |
| <a name="output_umi_resource_ids"></a> [umi_resource_ids](#output_umi_resource_ids) | The Azure resource IDs of the user-managed identities. Value will be null if var.umi_enabled is false. |
| <a name="output_umi_tenant_ids"></a> [umi_tenant_ids](#output_umi_tenant_ids) | The tenant IDs of the user-managed identities. Value will be null if var.umi_enabled is false. |
| <a name="output_virtual_network_resource_ids"></a> [virtual_network_resource_ids](#output_virtual_network_resource_ids) | Map of virtual network names to their resource IDs. |
<!-- END_TF_DOCS -->
