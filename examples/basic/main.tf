# Example: Basic Landing Zone Vending
#
# This example demonstrates deploying MULTIPLE landing zones in a SINGLE module call
# using variables with a terraform.tfvars file.
#
# The terraform.tfvars.example file shows how to define multiple landing zones
# (example-api-prod and example-web-dev) in the landing_zones map variable.
#
# Copy terraform.tfvars.example to terraform.tfvars and customize values.

module "landing_zones" {
  source = "../.."

  # Common configuration shared across all landing zones
  subscription_billing_scope       = var.subscription_billing_scope
  subscription_management_group_id = var.subscription_management_group_id
  hub_network_resource_id          = var.hub_network_resource_id
  github_organization              = var.github_organization
  azure_address_space              = var.azure_address_space
  tags                             = var.tags

  # Map of multiple landing zones to deploy in this single module call
  landing_zones = var.landing_zones
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
