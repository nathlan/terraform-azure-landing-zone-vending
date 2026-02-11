# Example: Basic Landing Zone Configuration

This example demonstrates a complete landing zone setup with:
- Production landing zone with virtual network
- Budget with email notifications
- GitHub federated credentials for OIDC

## Prerequisites

- Azure subscription with billing access
- Hub virtual network (if using hub peering)
- GitHub organization (if using federated credentials)

## Usage

1. Copy the example tfvars file and customize with your values:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your specific values
   ```

2. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Outputs

The module outputs subscription IDs, resource group IDs, virtual network IDs, and UMI details for all landing zones.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | >= 2.0, < 3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0, < 5.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9, < 1.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_landing_zones"></a> [landing\_zones](#module\_landing\_zones) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_address_space"></a> [azure\_address\_space](#input\_azure\_address\_space) | The base address space to use for IP address automation in CIDR notation. | `string` | n/a | yes |
| <a name="input_github_organization"></a> [github\_organization](#input\_github\_organization) | The GitHub organization name for federated credentials. | `string` | `null` | no |
| <a name="input_hub_network_resource_id"></a> [hub\_network\_resource\_id](#input\_hub\_network\_resource\_id) | The Azure resource ID of the hub virtual network for peering. | `string` | `null` | no |
| <a name="input_landing_zones"></a> [landing\_zones](#input\_landing\_zones) | Map of landing zones to create with their configurations. | <pre>map(object({<br>    workload                     = string<br>    env                          = string<br>    team                         = string<br>    location                     = string<br>    subscription_devtest_enabled = optional(bool, false)<br>    subscription_tags            = optional(map(string), {})<br>    dns_servers                  = optional(list(string), [])<br>    spoke_vnet = optional(object({<br>      ipv4_address_spaces = map(object({<br>        address_space_cidr = string<br>        subnets = map(object({<br>          subnet_prefixes = list(string)<br>        }))<br>      }))<br>    }))<br>    budget = optional(object({<br>      monthly_amount             = number<br>      alert_threshold_percentage = number<br>      alert_contact_emails       = list(string)<br>    }))<br>    federated_credentials_github = optional(object({<br>      repository = string<br>    }))<br>  }))</pre> | n/a | yes |
| <a name="input_subscription_billing_scope"></a> [subscription\_billing\_scope](#input\_subscription\_billing\_scope) | The billing scope for all subscription aliases created by this module. | `string` | n/a | yes |
| <a name="input_subscription_management_group_id"></a> [subscription\_management\_group\_id](#input\_subscription\_management\_group\_id) | The management group ID to associate all subscriptions with. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Common tags to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_calculated_address_prefixes"></a> [calculated\_address\_prefixes](#output\_calculated\_address\_prefixes) | Automatically calculated VNet address prefixes |
| <a name="output_resource_group_resource_ids"></a> [resource\_group\_resource\_ids](#output\_resource\_group\_resource\_ids) | Landing zone resource group IDs |
| <a name="output_subscription_ids"></a> [subscription\_ids](#output\_subscription\_ids) | Landing zone subscription IDs |
| <a name="output_umi_client_ids"></a> [umi\_client\_ids](#output\_umi\_client\_ids) | User-managed identity client IDs |
| <a name="output_virtual_network_resource_ids"></a> [virtual\_network\_resource\_ids](#output\_virtual\_network\_resource\_ids) | Landing zone virtual network IDs |
<!-- END_TF_DOCS -->
