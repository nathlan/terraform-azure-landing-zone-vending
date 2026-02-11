# Azure Landing Zone Vending Module

Terraform module for Azure Landing Zone subscription vending with Azure Verified Modules (AVM) integration, Azure naming conventions, and smart defaults.

## Features

- **Azure Naming Module Integration**: Automatic resource naming following Azure best practices
- **Time Provider**: Idempotent budget timestamps using HashiCorp time provider
- **Smart Defaults**: 70% code reduction with sensible defaults for all features
- **Landing Zones Map**: Manage multiple landing zones in a single module call
- **IP Address Automation**: Automatic VNet address space calculation
- **Subnet Support**: Create subnets with automatic CIDR calculation

## Usage

```hcl
module "landing_zones" {
  source  = "nathlan/landing-zone-vending/azurerm"
  version = "~> 3.0"

  subscription_billing_scope         = "YOUR_BILLING_SCOPE"
  subscription_management_group_id   = "Corp"
  hub_network_resource_id            = "/subscriptions/xxx/resourceGroups/rg-hub/providers/Microsoft.Network/virtualNetworks/vnet-hub"
  github_organization                = "yourorg"
  base_address_space                 = "10.100.0.0/16"

  tags = {
    managed_by = "terraform"
  }

  landing_zones = {
    example-api-prod = {
      workload = "example-api"
      env      = "prod"
      team     = "app-engineering"
      location = "australiaeast"

      address_space_required = "/24"
      subnets = {
        default = { subnet_prefix = "/26" }
        api     = { subnet_prefix = "/28" }
      }

      budgets = {
        amount         = 500
        threshold      = 80
        contact_emails = ["team@example.com"]
      }

      federated_credentials_github = {
        repository = "example-api-prod"
      }
    }
  }
}
```

## Examples

- [Basic example](./examples/basic) - Complete landing zone with VNet, budget, and federated credentials

## Breaking Changes in v3.0.0

This is a MAJOR version with breaking changes. Key changes:

- New `landing_zones` map variable structure
- Time provider required in `versions.tf`
- Auto-generated resource names (cannot override)
- Environment validation enforced (dev/test/prod only)
- Removed individual feature enable flags
- Simplified budget configuration

See [CHANGELOG.md](./CHANGELOG.md) for migration guide.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | >= 2.0, < 3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0, < 5.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9, < 1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_time"></a> [time](#provider\_time) | >= 0.9, < 1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ip_addresses"></a> [ip\_addresses](#module\_ip\_addresses) | Azure/avm-utl-network-ip-addresses/azurerm | ~> 0.1.0 |
| <a name="module_landing_zone_vending"></a> [landing\_zone\_vending](#module\_landing\_zone\_vending) | Azure/avm-ptn-alz-sub-vending/azure | ~> 0.1.0 |
| <a name="module_naming"></a> [naming](#module\_naming) | Azure/naming/azurerm | ~> 0.4.3 |
| <a name="module_naming_rg_identity"></a> [naming\_rg\_identity](#module\_naming\_rg\_identity) | Azure/naming/azurerm | ~> 0.4.3 |
| <a name="module_naming_rg_network"></a> [naming\_rg\_network](#module\_naming\_rg\_network) | Azure/naming/azurerm | ~> 0.4.3 |

## Resources

| Name | Type |
|------|------|
| [time_offset.budget_end](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/offset) | resource |
| [time_static.budget](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/static) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_base_address_space"></a> [base\_address\_space](#input\_base\_address\_space) | The base address space to use for IP address automation in CIDR notation (e.g., '10.100.0.0/16'). Required for automatic address space calculation. | `string` | n/a | yes |
| <a name="input_landing_zones"></a> [landing\_zones](#input\_landing\_zones) | Map of landing zones to create. Each landing zone is a complete Azure subscription with virtual network, identity, and optional budgets.<br><br>Required fields:<br>- workload: Short identifier for the workload (e.g., 'example-api')<br>- env: Environment (must be 'dev', 'test', or 'prod')<br>- team: Owning team name<br>- location: Azure region (e.g., 'australiaeast')<br><br>Optional fields:<br>- subscription\_devtest\_enabled: Create as DevTest subscription (default: false = Production)<br>- subscription\_tags: Additional tags for the subscription (merged with auto-generated tags)<br>- address\_space\_required: VNet prefix size (e.g., '/24') - omit to skip VNet creation<br>- hub\_peering\_enabled: Enable peering to hub VNet (default: true)<br>- dns\_servers: Custom DNS servers for VNet<br>- subnets: Map of subnets with subnet\_prefix (e.g., '/26')<br>- budgets: Budget configuration with amount, threshold, and contact\_emails<br>- federated\_credentials\_github: GitHub OIDC config with repository name<br><br>Example:<br>landing\_zones = {<br>  example-api-prod = {<br>    workload = "example-api"<br>    env      = "prod"<br>    team     = "app-engineering"<br>    location = "australiaeast"<br>    address\_space\_required = "/24"<br>    subnets = {<br>      default = { subnet\_prefix = "/26" }<br>    }<br>    budgets = {<br>      amount         = 500<br>      threshold      = 80<br>      contact\_emails = ["team@example.com"]<br>    }<br>  }<br>} | <pre>map(object({<br>    # Core Identity<br>    workload = string<br>    env      = string<br>    team     = string<br>    location = string<br><br>    # Optional: Subscription Configuration<br>    subscription_devtest_enabled = optional(bool, false)<br>    subscription_tags            = optional(map(string), {})<br><br>    # Optional: Networking Configuration<br>    address_space_required = optional(string)<br>    hub_peering_enabled    = optional(bool, true)<br>    dns_servers            = optional(list(string), [])<br>    subnets = optional(map(object({<br>      name          = optional(string)<br>      subnet_prefix = string<br>    })), {})<br><br>    # Optional: Budget Configuration<br>    budgets = optional(object({<br>      amount         = number<br>      threshold      = number<br>      contact_emails = list(string)<br>    }))<br><br>    # Optional: Federated Credentials<br>    federated_credentials_github = optional(object({<br>      repository = string<br>    }))<br>  }))</pre> | n/a | yes |
| <a name="input_subscription_billing_scope"></a> [subscription\_billing\_scope](#input\_subscription\_billing\_scope) | The billing scope for all subscription aliases created by this module. Required for creating new subscriptions. | `string` | n/a | yes |
| <a name="input_subscription_management_group_id"></a> [subscription\_management\_group\_id](#input\_subscription\_management\_group\_id) | The management group ID to associate all subscriptions with. | `string` | n/a | yes |
| <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry) | Enable telemetry via a customer usage attribution tag. | `bool` | `true` | no |
| <a name="input_github_organization"></a> [github\_organization](#input\_github\_organization) | The GitHub organization name for federated credentials. | `string` | `null` | no |
| <a name="input_hub_network_resource_id"></a> [hub\_network\_resource\_id](#input\_hub\_network\_resource\_id) | The Azure resource ID of the hub virtual network for peering. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Common tags to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_budget_resource_ids"></a> [budget\_resource\_ids](#output\_budget\_resource\_ids) | Map of landing zone keys to their budget resource IDs. |
| <a name="output_calculated_address_prefixes"></a> [calculated\_address\_prefixes](#output\_calculated\_address\_prefixes) | The automatically calculated address prefixes for virtual networks. |
| <a name="output_landing_zone_names"></a> [landing\_zone\_names](#output\_landing\_zone\_names) | Map of landing zone keys to their auto-generated subscription names. |
| <a name="output_resource_group_resource_ids"></a> [resource\_group\_resource\_ids](#output\_resource\_group\_resource\_ids) | Map of landing zone keys to their resource group resource IDs. |
| <a name="output_subscription_ids"></a> [subscription\_ids](#output\_subscription\_ids) | Map of landing zone keys to their subscription IDs. |
| <a name="output_subscription_resource_ids"></a> [subscription\_resource\_ids](#output\_subscription\_resource\_ids) | Map of landing zone keys to their subscription resource IDs. |
| <a name="output_umi_client_ids"></a> [umi\_client\_ids](#output\_umi\_client\_ids) | Map of landing zone keys to their UMI client IDs. |
| <a name="output_umi_principal_ids"></a> [umi\_principal\_ids](#output\_umi\_principal\_ids) | Map of landing zone keys to their UMI principal IDs (object IDs). |
| <a name="output_umi_resource_ids"></a> [umi\_resource\_ids](#output\_umi\_resource\_ids) | Map of landing zone keys to their UMI resource IDs. |
| <a name="output_virtual_network_address_spaces"></a> [virtual\_network\_address\_spaces](#output\_virtual\_network\_address\_spaces) | Map of landing zone keys to their virtual network address spaces. |
| <a name="output_virtual_network_resource_ids"></a> [virtual\_network\_resource\_ids](#output\_virtual\_network\_resource\_ids) | Map of landing zone keys to their virtual network resource IDs. |
<!-- END_TF_DOCS -->

## License

MIT License. See [LICENSE](./LICENSE) for details.
