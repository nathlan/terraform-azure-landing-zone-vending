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
