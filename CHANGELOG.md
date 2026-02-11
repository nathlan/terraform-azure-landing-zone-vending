# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.0.0] - 2026-02-11

### Added

- **Azure Naming Module Integration**: All resources now use Azure naming conventions via `Azure/naming/azurerm` module (~> 0.4.3)
- **Time Provider for Budgets**: Budget timestamps now use HashiCorp time provider for idempotent dates
- **Landing Zones Map**: New `landing_zones` map variable to manage multiple landing zones in a single call
- **Smart Defaults**: Resource groups and UMIs are always created with sensible defaults
- **Subnet Support**: Virtual networks now support subnet configuration with automatic CIDR calculation
- **3-Layer Tag Merging**: Common tags + auto-generated tags + custom tags
- **Environment Validation**: Landing zone `env` must be `dev`, `test`, or `prod`
- **Resource Abbreviations**: Internal `locals` for resource types not in Azure naming module

### Changed

- **BREAKING**: Replaced flat variables with `landing_zones` map structure
- **BREAKING**: `subscription_workload` replaced with `subscription_devtest_enabled` boolean
- **BREAKING**: Removed `ip_address_automation_enabled` (always enabled)
- **BREAKING**: Renamed `ip_address_automation_address_space` to `base_address_space`
- **BREAKING**: Removed `ip_address_automation_vnet_prefix_sizes` (calculated from landing_zones)
- **BREAKING**: Resource names are now auto-generated (cannot be overridden)
- **BREAKING**: All feature enable flags removed (features enabled based on config presence)

### Migration from v2.x to v3.0

#### 1. Update versions.tf

Add time provider requirement:

```hcl
terraform {
  required_providers {
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9, < 1.0"
    }
  }
}
```

#### 2. Restructure Configuration

**Before (v2.x):**
```hcl
module "landing_zone" {
  source  = "nathlan/landing-zone-vending/azurerm"
  version = "~> 2.0"

  location                      = "australiaeast"
  subscription_alias_enabled    = true
  subscription_billing_scope    = "YOUR_BILLING_SCOPE"
  subscription_display_name     = "sub-example-api-prod"
  subscription_alias_name       = "sub-example-api-prod"
  subscription_workload         = "Production"
  # ... 90 more lines
}
```

**After (v3.0):**
```hcl
module "landing_zones" {
  source  = "nathlan/landing-zone-vending/azurerm"
  version = "~> 3.0"

  subscription_billing_scope       = "YOUR_BILLING_SCOPE"
  subscription_management_group_id = "Corp"
  base_address_space               = "10.100.0.0/16"

  landing_zones = {
    example-api-prod = {
      workload = "example-api"
      env      = "prod"
      team     = "app-engineering"
      location = "australiaeast"
      address_space_required = "/24"
      # ... ~20 lines
    }
  }
}
```

#### 3. Remove Manual Resource Names

All resource names are now auto-generated. Remove:
- `subscription_display_name`
- `subscription_alias_name`
- Virtual network `name` fields
- Resource group `name` fields
- User-managed identity `name` fields
- Budget `name` fields

Resource names follow patterns:
- Subscriptions: `sub-{workload}-{env}`
- Resource Groups: `rg-{purpose}-{workload}-{env}`
- Virtual Networks: `vnet-{workload}-{env}`
- UMIs: `id-{workload}-{env}-{purpose}`
- Budgets: `budget-{workload}-{env}`

#### 4. Update Budget Configuration

**Before:**
```hcl
budgets = {
  monthly = {
    name              = "budget-example-api-prod"
    amount            = 500
    time_grain        = "Monthly"
    time_period_start = "2024-01-01T00:00:00Z"
    time_period_end   = "2025-01-01T00:00:00Z"
    notifications = {
      threshold = {
        enabled        = true
        operator       = "GreaterThan"
        threshold      = 80
        contact_emails = ["team@example.com"]
      }
    }
  }
}
```

**After:**
```hcl
budgets = {
  amount         = 500
  threshold      = 80
  contact_emails = ["team@example.com"]
}
```

#### 5. Update Virtual Network Configuration

**Before:**
```hcl
virtual_networks = {
  spoke = {
    name          = "vnet-example-api-prod"
    address_space = ["10.100.0.0/24"]
    # ...
  }
}
```

**After:**
```hcl
address_space_required = "/24"
subnets = {
  default = { subnet_prefix = "/26" }
}
```

### Removed

- `subscription_alias_enabled` (always enabled)
- `resource_group_creation_enabled` (always enabled)
- `virtual_network_enabled` (enabled if `address_space_required` provided)
- `umi_enabled` (always enabled)
- `budget_enabled` (enabled if `budgets` provided)
- `role_assignment_enabled` (configured via UMI role_assignments)

## [2.1.0] - 2026-02-09

### Added

- User-Managed Identity (UMI) support with federated credentials
- Budget creation with notifications
- GitHub and Terraform Cloud OIDC support

## [2.0.0] - 2026-02-08

### Added

- IP address automation using Azure AVM utility module
- Automatic address space calculation for virtual networks

## [1.0.0] - 2026-02-07

### Added

- Initial release wrapping Azure AVM pattern module
- Subscription alias creation
- Resource group creation
- Virtual network creation with hub peering
- Role assignments

[3.0.0]: https://github.com/nathlan/terraform-azurerm-landing-zone-vending/compare/v2.1.0...v3.0.0
[2.1.0]: https://github.com/nathlan/terraform-azurerm-landing-zone-vending/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/nathlan/terraform-azurerm-landing-zone-vending/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/nathlan/terraform-azurerm-landing-zone-vending/releases/tag/v1.0.0
