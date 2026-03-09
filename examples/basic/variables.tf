# ========================================
# Common Configuration
# ========================================

variable "subscription_billing_scope" {
  type        = string
  description = "The billing scope for all subscription aliases created by this module."
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
  description = "The base address space to use for IP address automation in CIDR notation."
}

variable "tags" {
  type        = map(string)
  description = "Common tags to apply to all resources."
  default     = {}
}

variable "subscription_devtest_supported" {
  type        = bool
  description = "Whether DevTest subscriptions are supported."
  default     = false
}

# ========================================
# Landing Zones Configuration
# ========================================

variable "landing_zones" {
  type = map(object({
    workload          = string
    env               = string
    team              = string
    location          = string
    subscription_tags = optional(map(string), {})
    dns_servers       = optional(list(string), [])
    spoke_vnet = optional(object({
      ipv4_address_spaces = map(object({
        vnet_address_space_prefix = string
        subnets = map(object({
          subnet_prefixes = list(string)
        }))
      }))
    }))
    budget = optional(object({
      monthly_amount             = number
      alert_threshold_percentage = number
      alert_contact_emails       = list(string)
    }))
    federated_credentials_github = optional(object({
      repository = string
    }))
  }))
  description = "Map of landing zones to create with their configurations."
}
