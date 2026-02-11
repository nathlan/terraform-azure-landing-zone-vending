# Example: Basic Landing Zone Vending
#
# This example demonstrates using variables with a terraform.tfvars file.
# Copy terraform.tfvars.example to terraform.tfvars and customize values.

module "landing_zones" {
  source = "../.."

  subscription_billing_scope       = var.subscription_billing_scope
  subscription_management_group_id = var.subscription_management_group_id
  hub_network_resource_id          = var.hub_network_resource_id
  github_organization              = var.github_organization
  base_address_space               = var.base_address_space
  tags                             = var.tags
  landing_zones                    = var.landing_zones
}

# Outputs

output "subscription_ids" {
  description = "Landing zone subscription IDs"
  value       = module.landing_zones.subscription_ids
}

output "resource_group_resource_ids" {
  description = "Landing zone resource group IDs"
  value       = module.landing_zones.resource_group_resource_ids
}

output "virtual_network_resource_ids" {
  description = "Landing zone virtual network IDs"
  value       = module.landing_zones.virtual_network_resource_ids
}

output "umi_client_ids" {
  description = "User-managed identity client IDs"
  value       = module.landing_zones.umi_client_ids
}

output "calculated_address_prefixes" {
  description = "Automatically calculated VNet address prefixes"
  value       = module.landing_zones.calculated_address_prefixes
}
