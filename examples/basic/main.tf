# Example: Basic Landing Zone Vending

module "landing_zones" {
  source = "../.."

  subscription_billing_scope       = "YOUR_BILLING_SCOPE_HERE"  # Replace with your billing scope
  subscription_management_group_id = "Corp"
  hub_network_resource_id          = "/subscriptions/xxx/resourceGroups/rg-hub/providers/Microsoft.Network/virtualNetworks/vnet-hub"
  github_organization              = "yourorg"
  base_address_space               = "10.100.0.0/16"

  tags = {
    managed_by = "terraform"
    environment_type = "example"
  }

  landing_zones = {
    example-api-prod = {
      workload = "example-api"
      env      = "prod"
      team     = "app-engineering"
      location = "australiaeast"

      subscription_tags = {
        cost_centre = "IT-DEV-002"
        criticality = "high"
      }

      address_space_required = "/24"
      hub_peering_enabled    = true

      subnets = {
        default = {
          subnet_prefix = "/26"
        }
        api = {
          subnet_prefix = "/28"
        }
      }

      budgets = {
        amount         = 500
        threshold      = 80
        contact_emails = ["dev-team@example.com"]
      }

      federated_credentials_github = {
        repository = "example-api-prod"
      }
    }

    example-web-dev = {
      workload = "example-web"
      env      = "dev"
      team     = "web-engineering"
      location = "australiacentral"

      subscription_devtest_enabled = true
      subscription_tags = {
        cost_centre = "IT-DEV-001"
      }

      address_space_required = "/25"

      subnets = {
        default = {
          subnet_prefix = "/27"
        }
      }

      budgets = {
        amount         = 100
        threshold      = 90
        contact_emails = ["web-team@example.com"]
      }

      federated_credentials_github = {
        repository = "example-web-dev"
      }
    }
  }
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
