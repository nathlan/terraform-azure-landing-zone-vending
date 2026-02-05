# Location
variable "location" {
  type        = string
  description = "The default location of resources created by this module. Virtual networks will be created in this location unless overridden."
}

# Core subscription configuration
variable "subscription_alias_enabled" {
  type        = bool
  description = "Whether to create a new subscription using the alias API."
  default     = false
}

variable "subscription_billing_scope" {
  type        = string
  description = "The billing scope to use when creating the subscription alias. Only required when subscription_alias_enabled is true."
  default     = null
}

variable "subscription_display_name" {
  type        = string
  description = "The display name for the subscription."
  default     = null
}

variable "subscription_alias_name" {
  type        = string
  description = "The name of the subscription alias."
  default     = null
}

variable "subscription_workload" {
  type        = string
  description = "The workload type for the subscription. Valid values are 'Production' and 'DevTest'."
  default     = null

  validation {
    condition     = var.subscription_workload == null || contains(["Production", "DevTest"], var.subscription_workload)
    error_message = "subscription_workload must be either 'Production' or 'DevTest'."
  }
}

variable "subscription_management_group_id" {
  type        = string
  description = "The management group ID to place the subscription in."
  default     = null
}

variable "subscription_tags" {
  type        = map(string)
  description = "Tags to apply to the subscription."
  default     = {}
}

variable "subscription_management_group_association_enabled" {
  type        = bool
  description = "Whether to associate the subscription with a management group."
  default     = false
}

# Resource group configuration
variable "resource_group_creation_enabled" {
  type        = bool
  description = "Whether to create resource groups."
  default     = false
}

variable "resource_groups" {
  type = map(object({
    name     = string
    location = optional(string)
    tags     = optional(map(string), {})
  }))
  description = "Map of resource groups to create."
  default     = {}
}

# Role assignment configuration
variable "role_assignment_enabled" {
  type        = bool
  description = "Whether to create role assignments for the subscription."
  default     = false
}

variable "role_assignments" {
  type = map(object({
    principal_id                     = string
    definition                       = string
    relative_scope                   = string
    condition                        = optional(string)
    condition_version                = optional(string)
    description                      = optional(string)
    principal_type                   = optional(string)
    skip_service_principal_aad_check = optional(bool, false)
  }))
  description = "Map of role assignments to create for the subscription."
  default     = {}
}

# Virtual network configuration
variable "virtual_network_enabled" {
  type        = bool
  description = "Whether to create virtual networks."
  default     = false
}

variable "virtual_networks" {
  type = map(object({
    name                    = string
    address_space           = list(string)
    resource_group_key      = string
    location                = optional(string)
    dns_servers             = optional(list(string), [])
    ddos_protection_plan_id = optional(string)
    hub_network_resource_id = optional(string)
    hub_peering_enabled     = optional(bool, false)
    mesh_peering_enabled    = optional(bool, false)
    tags                    = optional(map(string), {})
  }))
  description = "Map of virtual networks to create."
  default     = {}
}

# Telemetry configuration
variable "enable_telemetry" {
  type        = bool
  description = "Enable telemetry via a customer usage attribution tag. This allows Microsoft to track usage of this module."
  default     = true
}
