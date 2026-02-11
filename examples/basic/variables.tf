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

# ========================================
# Landing Zones Configuration
# ========================================

variable "landing_zones" {
  type = map(object({
    workload                     = string
    env                          = string
    team                         = string
    location                     = string
    subscription_devtest_enabled = optional(bool, false)
    subscription_tags            = optional(map(string), {})
    address_space_required       = optional(string)
    hub_peering_enabled          = optional(bool, true)
    dns_servers                  = optional(list(string), [])
    subnets = optional(map(object({
      name          = optional(string)
      subnet_prefix = string
    })), {})
    budgets = optional(object({
      amount         = number
      threshold      = number
      contact_emails = list(string)
    }))
    federated_credentials_github = optional(object({
      repository = string
    }))
  }))
  description = "Map of landing zones to create with their configurations."
}
