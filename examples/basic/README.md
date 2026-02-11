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

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_calculated_address_prefixes"></a> [calculated\_address\_prefixes](#output\_calculated\_address\_prefixes) | Automatically calculated VNet address prefixes |
| <a name="output_resource_group_resource_ids"></a> [resource\_group\_resource\_ids](#output\_resource\_group\_resource\_ids) | Landing zone resource group IDs |
| <a name="output_subscription_ids"></a> [subscription\_ids](#output\_subscription\_ids) | Landing zone subscription IDs |
| <a name="output_umi_client_ids"></a> [umi\_client\_ids](#output\_umi\_client\_ids) | User-managed identity client IDs |
| <a name="output_virtual_network_resource_ids"></a> [virtual\_network\_resource\_ids](#output\_virtual\_network\_resource\_ids) | Landing zone virtual network IDs |
<!-- END_TF_DOCS -->
