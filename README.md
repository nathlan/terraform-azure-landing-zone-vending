# Azure Landing Zone Vending Module

Terraform module for Azure Landing Zone subscription vending with Azure Verified Modules (AVM) integration, automatic naming, and smart defaults.

## Usage

```hcl
module "landing_zones" {
  source  = "github.com/nathlan/terraform-azure-landing-zone-vending"
  version = "~> 1.0"

  subscription_billing_scope       = "/providers/Microsoft.Billing/billingAccounts/xxx/enrollmentAccounts/xxx"
  subscription_management_group_id = "sandboxes"
  subscription_devtest_supported   = true
  hub_network_resource_id          = "/subscriptions/xxx/resourceGroups/rg-hub/providers/Microsoft.Network/virtualNetworks/vnet-hub"
  azure_address_space              = "10.100.0.0/16"

  landing_zones = {
    example-api-dev = {
      workload = "example-api"
      env      = "dev"
      team     = "app-engineering"
      location = "australiaeast"

      spoke_vnet = {
        ipv4_address_spaces = {
          default = {
            vnet_address_space_prefix = "/24"
            subnets = {
              apim = {
                subnet_prefixes = ["/26", "/27"]
              }
            }
          }
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
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.10 |
| <a name="requirement_azapi"></a> [azapi](#requirement_azapi) | ~> 2.5 |
| <a name="requirement_modtm"></a> [modtm](#requirement_modtm) | ~> 0.3 |
| <a name="requirement_random"></a> [random](#requirement_random) | >= 3.3.2 |
| <a name="requirement_time"></a> [time](#requirement_time) | >= 0.9, < 1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_time"></a> [time](#provider_time) | >= 0.9, < 1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ip_addresses"></a> [ip_addresses](#module_ip_addresses) | Azure/avm-utl-network-ip-addresses/azurerm | ~> 0.1.0 |
| <a name="module_landing_zone_vending"></a> [landing_zone_vending](#module_landing_zone_vending) | Azure/avm-ptn-alz-sub-vending/azure | ~> 0.1.0 |
| <a name="module_naming"></a> [naming](#module_naming) | Azure/naming/azurerm | ~> 0.4.3 |
| <a name="module_naming_rg_identity"></a> [naming_rg_identity](#module_naming_rg_identity) | Azure/naming/azurerm | ~> 0.4.3 |
| <a name="module_naming_rg_network"></a> [naming_rg_network](#module_naming_rg_network) | Azure/naming/azurerm | ~> 0.4.3 |

## Resources

| Name | Type |
|------|------|
| [time_offset.budget_end](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/offset) | resource |
| [time_static.budget](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/static) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_address_space"></a> [azure_address_space](#input_azure_address_space) | The base address space to use for IP address automation in CIDR notation (e.g., '10.100.0.0/16'). Required for automatic address space calculation. | `string` | n/a | yes |
| <a name="input_landing_zones"></a> [landing_zones](#input_landing_zones) | Map of landing zones to create. Each landing zone is a complete Azure subscription with virtual network, identity, and optional budgets.<br/><br/>Required fields:<br/>- workload: Short identifier for the workload (e.g., 'example-api')<br/>- env: Environment (must be 'dev', 'test', or 'prod')<br/>- team: Owning team name<br/>- location: Azure region (e.g., 'australiaeast')<br/><br/>Optional fields:<br/>- subscription_tags: Additional tags for the subscription (merged with auto-generated tags)<br/>- dns_servers: Custom DNS servers for VNet<br/>- spoke_vnet: Spoke VNet configuration with nested address spaces and subnets (omit to skip VNet creation)<br/>  - ipv4_address_spaces: Map of address spaces, each with:<br/>    - vnet_address_space_prefix: Prefix size (e.g., '/24')<br/>    - subnets: Map of subnets, each with:<br/>      - subnet_prefixes: List of subnet prefix sizes (e.g., ['/26', '/28'])<br/>- budget: Budget configuration with optional monthly_amount (default: 1000), alert_threshold_percentage, and alert_contact_emails<br/>- federated_credentials_github: GitHub OIDC config with repository name<br/><br/>Example:<br/>landing_zones = {<br/>  example-api-prod = {<br/>    workload = "example-api"<br/>    env      = "prod"<br/>    team     = "app-engineering"<br/>    location = "australiaeast"<br/>    spoke_vnet = {<br/>      ipv4_address_spaces = {<br/>        default_address_space = {<br/>          vnet_address_space_prefix = "/23"<br/>          subnets = {<br/>            workload = {<br/>              subnet_prefixes = ["/27", "/26"]<br/>            }<br/>          }<br/>        }<br/>      }<br/>    }<br/>    budget = {<br/>      monthly_amount             = 1000<br/>      alert_threshold_percentage = 80<br/>      alert_contact_emails       = ["team@example.com"]<br/>    }<br/>  }<br/>} | <pre>map(object({<br/>    # Core Identity<br/>    workload = string<br/>    env      = string<br/>    team     = string<br/>    location = string<br/><br/>    # Optional: Subscription Configuration<br/>    subscription_tags = optional(map(string), {})<br/><br/>    # Optional: Networking Configuration<br/>    dns_servers = optional(list(string), [])<br/>    spoke_vnet = optional(object({<br/>      ipv4_address_spaces = map(object({<br/>        vnet_address_space_prefix = string<br/>        subnets = map(object({<br/>          subnet_prefixes = list(string)<br/>        }))<br/>      }))<br/>    }))<br/><br/>    # Optional: Budget Configuration<br/>    budget = optional(object({<br/>      monthly_amount             = optional(number, 1000)<br/>      alert_threshold_percentage = number<br/>      alert_contact_emails       = list(string)<br/>    }))<br/><br/>    # Optional: Federated Credentials<br/>    federated_credentials_github = optional(object({<br/>      repository = string<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_subscription_billing_scope"></a> [subscription_billing_scope](#input_subscription_billing_scope) | The billing scope for all subscription aliases created by this module. Required for creating new subscriptions. | `string` | n/a | yes |
| <a name="input_subscription_management_group_id"></a> [subscription_management_group_id](#input_subscription_management_group_id) | The management group ID to associate all subscriptions with. | `string` | n/a | yes |
| <a name="input_enable_telemetry"></a> [enable_telemetry](#input_enable_telemetry) | Enable telemetry via a customer usage attribution tag. | `bool` | `true` | no |
| <a name="input_github_organization"></a> [github_organization](#input_github_organization) | The GitHub organization name for federated credentials. | `string` | `null` | no |
| <a name="input_hub_network_resource_id"></a> [hub_network_resource_id](#input_hub_network_resource_id) | The Azure resource ID of the hub virtual network for peering. | `string` | `null` | no |
| <a name="input_subscription_devtest_supported"></a> [subscription_devtest_supported](#input_subscription_devtest_supported) | Whether DevTest subscriptions are supported. When true, landing zones with env 'dev' or 'test' will automatically use the DevTest subscription workload type. When false, all subscriptions are created as Production. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input_tags) | Common tags to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_budget_resource_ids"></a> [budget_resource_ids](#output_budget_resource_ids) | Map of landing zone keys to their budget resource IDs. |
| <a name="output_calculated_address_prefixes"></a> [calculated_address_prefixes](#output_calculated_address_prefixes) | The automatically calculated address prefixes for virtual networks. |
| <a name="output_landing_zone_names"></a> [landing_zone_names](#output_landing_zone_names) | Map of landing zone keys to their auto-generated subscription names. |
| <a name="output_resource_group_resource_ids"></a> [resource_group_resource_ids](#output_resource_group_resource_ids) | Map of landing zone keys to their resource group resource IDs. |
| <a name="output_subscription_ids"></a> [subscription_ids](#output_subscription_ids) | Map of landing zone keys to their subscription IDs. |
| <a name="output_subscription_resource_ids"></a> [subscription_resource_ids](#output_subscription_resource_ids) | Map of landing zone keys to their subscription resource IDs. |
| <a name="output_tfapply_client_ids"></a> [tfapply_client_ids](#output_tfapply_client_ids) | Map of landing zone keys to their Terraform apply UMI client IDs (id-<workload>-<env>-<workload>-tfapply, Owner role). |
| <a name="output_tfplan_client_ids"></a> [tfplan_client_ids](#output_tfplan_client_ids) | Map of landing zone keys to their Terraform plan UMI client IDs (id-<workload>-<env>-<workload>-tfplan, Reader role). |
| <a name="output_umi_client_ids"></a> [umi_client_ids](#output_umi_client_ids) | Map of landing zone keys to their UMI client IDs. |
| <a name="output_umi_principal_ids"></a> [umi_principal_ids](#output_umi_principal_ids) | Map of landing zone keys to their UMI principal IDs (object IDs). |
| <a name="output_umi_resource_ids"></a> [umi_resource_ids](#output_umi_resource_ids) | Map of landing zone keys to their UMI resource IDs. |
| <a name="output_virtual_network_address_spaces"></a> [virtual_network_address_spaces](#output_virtual_network_address_spaces) | Map of landing zone keys to their virtual network address spaces. |
| <a name="output_virtual_network_resource_ids"></a> [virtual_network_resource_ids](#output_virtual_network_resource_ids) | Map of landing zone keys to their virtual network resource IDs. |
<!-- END_TF_DOCS -->

## License

MIT License. See [LICENSE](./LICENSE) for details.
