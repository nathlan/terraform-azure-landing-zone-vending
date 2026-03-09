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
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.9 |
| <a name="requirement_azapi"></a> [azapi](#requirement_azapi) | >= 2.0, < 3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm) | >= 4.0, < 5.0 |
| <a name="requirement_time"></a> [time](#requirement_time) | >= 0.9, < 1.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_landing_zones"></a> [landing_zones](#module_landing_zones) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_address_space"></a> [azure_address_space](#input_azure_address_space) | The base address space to use for IP address automation in CIDR notation. | `string` | n/a | yes |
| <a name="input_landing_zones"></a> [landing_zones](#input_landing_zones) | Map of landing zones to create with their configurations. | <pre>map(object({<br/>    workload          = string<br/>    env               = string<br/>    team              = string<br/>    location          = string<br/>    subscription_tags = optional(map(string), {})<br/>    dns_servers       = optional(list(string), [])<br/>    spoke_vnet = optional(object({<br/>      ipv4_address_spaces = map(object({<br/>        vnet_address_space_prefix = string<br/>        subnets = map(object({<br/>          subnet_prefixes = list(string)<br/>        }))<br/>      }))<br/>    }))<br/>    budget = optional(object({<br/>      monthly_amount             = number<br/>      alert_threshold_percentage = number<br/>      alert_contact_emails       = list(string)<br/>    }))<br/>    federated_credentials_github = optional(object({<br/>      repository = string<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_subscription_billing_scope"></a> [subscription_billing_scope](#input_subscription_billing_scope) | The billing scope for all subscription aliases created by this module. | `string` | n/a | yes |
| <a name="input_subscription_management_group_id"></a> [subscription_management_group_id](#input_subscription_management_group_id) | The management group ID to associate all subscriptions with. | `string` | n/a | yes |
| <a name="input_github_organization"></a> [github_organization](#input_github_organization) | The GitHub organization name for federated credentials. | `string` | `null` | no |
| <a name="input_hub_network_resource_id"></a> [hub_network_resource_id](#input_hub_network_resource_id) | The Azure resource ID of the hub virtual network for peering. | `string` | `null` | no |
| <a name="input_subscription_devtest_supported"></a> [subscription_devtest_supported](#input_subscription_devtest_supported) | Whether DevTest subscriptions are supported. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input_tags) | Common tags to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_calculated_address_prefixes"></a> [calculated_address_prefixes](#output_calculated_address_prefixes) | Automatically calculated VNet address prefixes |
| <a name="output_resource_group_resource_ids"></a> [resource_group_resource_ids](#output_resource_group_resource_ids) | Landing zone resource group IDs |
| <a name="output_subscription_ids"></a> [subscription_ids](#output_subscription_ids) | Landing zone subscription IDs |
| <a name="output_tfapply_client_ids"></a> [tfapply_client_ids](#output_tfapply_client_ids) | Terraform apply UMI client IDs (Owner role) |
| <a name="output_tfplan_client_ids"></a> [tfplan_client_ids](#output_tfplan_client_ids) | Terraform plan UMI client IDs (Reader role) |
| <a name="output_umi_client_ids"></a> [umi_client_ids](#output_umi_client_ids) | User-managed identity client IDs |
| <a name="output_virtual_network_resource_ids"></a> [virtual_network_resource_ids](#output_virtual_network_resource_ids) | Landing zone virtual network IDs |
<!-- END_TF_DOCS -->
