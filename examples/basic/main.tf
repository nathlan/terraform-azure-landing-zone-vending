module "landing_zone" {
  source = "../.."

  location = "australiaeast"

  subscription_alias_enabled       = false
  subscription_display_name        = "example-workload-subscription"
  subscription_alias_name          = "example-workload-sub"
  subscription_workload            = "Production"
  subscription_management_group_id = "/providers/Microsoft.Management/managementGroups/landingzones"

  subscription_tags = {
    Environment = "Production"
    CostCenter  = "Engineering"
    ManagedBy   = "Terraform"
  }

  enable_telemetry = true
}
