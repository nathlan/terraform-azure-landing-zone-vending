# ========================================
# Common Configuration
# ========================================

variable "subscription_billing_scope" {
  type        = string
  description = "The billing scope for all subscription aliases created by this module. Required for creating new subscriptions."
}

variable "subscription_management_group_id" {
  type        = string
  description = "The management group ID to associate all subscriptions with."
}

variable "hub_network_resource_id" {
  type        = string
  description = "The Azure resource ID of the hub virtual network for peering."
  default     = null
}

variable "github_organization" {
  type        = string
  description = "The GitHub organization name for federated credentials."
  default     = null
}

variable "azure_address_space" {
  type        = string
  description = "The base address space to use for IP address automation in CIDR notation (e.g., '10.100.0.0/16'). Required for automatic address space calculation."

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.azure_address_space))
    error_message = "azure_address_space must be a valid CIDR notation (e.g., '10.100.0.0/16')."
  }
}

variable "tags" {
  type        = map(string)
  description = "Common tags to apply to all resources."
  default     = {}
}

variable "enable_telemetry" {
  type        = bool
  description = "Enable telemetry via a customer usage attribution tag."
  default     = true
}

# ========================================
# Landing Zones Configuration
# ========================================

variable "landing_zones" {
  type = map(object({
    # Core Identity
    workload = string
    env      = string
    team     = string
    location = string

    # Optional: Subscription Configuration
    subscription_devtest_enabled = optional(bool, false)
    subscription_tags            = optional(map(string), {})

    # Optional: Networking Configuration
    address_space_required = optional(string)
    hub_peering_enabled    = optional(bool, true)
    dns_servers            = optional(list(string), [])
    subnets = optional(map(object({
      name          = optional(string)
      subnet_prefix = string
    })), {})

    # Optional: Budget Configuration
    budget = optional(object({
      monthly_amount                = number
      alert_threshold_percentage    = number
      alert_contact_emails          = list(string)
    }))

    # Optional: Federated Credentials
    federated_credentials_github = optional(object({
      repository = string
    }))
  }))

  description = <<-EOT
    Map of landing zones to create. Each landing zone is a complete Azure subscription with virtual network, identity, and optional budgets.

    Required fields:
    - workload: Short identifier for the workload (e.g., 'example-api')
    - env: Environment (must be 'dev', 'test', or 'prod')
    - team: Owning team name
    - location: Azure region (e.g., 'australiaeast')

    Optional fields:
    - subscription_devtest_enabled: Create as DevTest subscription (default: false = Production)
    - subscription_tags: Additional tags for the subscription (merged with auto-generated tags)
    - address_space_required: VNet prefix size (e.g., '/24') - omit to skip VNet creation
    - hub_peering_enabled: Enable peering to hub VNet (default: true)
    - dns_servers: Custom DNS servers for VNet
    - subnets: Map of subnets with subnet_prefix (e.g., '/26')
    - budget: Budget configuration with monthly_amount, alert_threshold_percentage, and alert_contact_emails
    - federated_credentials_github: GitHub OIDC config with repository name

    Example:
    landing_zones = {
      example-api-prod = {
        workload = "example-api"
        env      = "prod"
        team     = "app-engineering"
        location = "australiaeast"
        address_space_required = "/24"
        subnets = {
          default = { subnet_prefix = "/26" }
        }
        budgets = {
          monthly_amount             = 500
          alert_threshold_percentage = 80
          alert_contact_emails       = ["team@example.com"]
        }
      }
    }
  EOT

  validation {
    condition = alltrue([
      for lz_key, lz in var.landing_zones :
      contains(["dev", "test", "prod"], lz.env)
    ])
    error_message = "Each landing zone 'env' must be 'dev', 'test', or 'prod'."
  }

  validation {
    condition = alltrue([
      for lz_key, lz in var.landing_zones :
      lz.address_space_required == null || can(regex("^/[0-9]{1,2}$", lz.address_space_required))
    ])
    error_message = "address_space_required must be in format '/XX' (e.g., '/24')."
  }
}
