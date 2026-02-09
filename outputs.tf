output "subscription_id" {
  description = "The ID of the subscription."
  value       = module.landing_zone_vending.subscription_id
}

output "subscription_resource_id" {
  description = "The resource ID of the subscription."
  value       = module.landing_zone_vending.subscription_resource_id
}

output "resource_group_resource_ids" {
  description = "Map of resource group names to their resource IDs."
  value       = module.landing_zone_vending.resource_group_resource_ids
}

output "virtual_network_resource_ids" {
  description = "Map of virtual network names to their resource IDs."
  value       = module.landing_zone_vending.virtual_network_resource_ids
}

output "route_table_resource_ids" {
  description = "Map of route table names to their resource IDs."
  value       = module.landing_zone_vending.route_table_resource_ids
}

output "management_group_subscription_association_id" {
  description = "The ID of the management group subscription association."
  value       = module.landing_zone_vending.management_group_subscription_association_id
}

# User-Managed Identity outputs
output "umi_client_ids" {
  description = "The client IDs of the user-managed identities. Value will be null if var.umi_enabled is false."
  value       = module.landing_zone_vending.umi_client_ids
}

output "umi_principal_ids" {
  description = "The principal IDs (object IDs) of the user-managed identities. Value will be null if var.umi_enabled is false."
  value       = module.landing_zone_vending.umi_principal_ids
}

output "umi_resource_ids" {
  description = "The Azure resource IDs of the user-managed identities. Value will be null if var.umi_enabled is false."
  value       = module.landing_zone_vending.umi_resource_ids
}

output "umi_tenant_ids" {
  description = "The tenant IDs of the user-managed identities. Value will be null if var.umi_enabled is false."
  value       = module.landing_zone_vending.umi_tenant_ids
}

# Budget outputs
output "budget_resource_ids" {
  description = "The created budget resource IDs, expressed as a map."
  value       = module.landing_zone_vending.budget_resource_id
}
