# Landing Zone Vending Module
# Wraps Azure Verified Module for ALZ Subscription Vending

module "landing_zone_vending" {
  source  = "Azure/avm-ptn-alz-sub-vending/azure"
  version = "0.1.0"

  # Required location
  location = var.location

  # Subscription configuration
  subscription_alias_enabled                        = var.subscription_alias_enabled
  subscription_billing_scope                        = var.subscription_billing_scope
  subscription_display_name                         = var.subscription_display_name
  subscription_alias_name                           = var.subscription_alias_name
  subscription_workload                             = var.subscription_workload
  subscription_management_group_id                  = var.subscription_management_group_id
  subscription_management_group_association_enabled = var.subscription_management_group_association_enabled
  subscription_tags                                 = var.subscription_tags

  # Resource groups
  resource_group_creation_enabled = var.resource_group_creation_enabled
  resource_groups                 = var.resource_groups

  # Role assignments
  role_assignment_enabled = var.role_assignment_enabled
  role_assignments        = var.role_assignments

  # Virtual networks
  virtual_network_enabled = var.virtual_network_enabled
  virtual_networks        = var.virtual_networks

  # User-Managed Identities
  umi_enabled             = var.umi_enabled
  user_managed_identities = var.user_managed_identities

  # Budgets
  budget_enabled = var.budget_enabled
  budgets        = var.budgets

  # Telemetry
  enable_telemetry = var.enable_telemetry
}
