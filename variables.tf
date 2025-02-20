# -------------------- General Variables --------------------

variable "resource_group_name" {
  description = "The name of the Resource Group"
  type        = string
}

variable "location" {
  description = "Location for the resources"
  type        = string
}

variable "project" {
  description = "The project name, used as a prefix for the network watcher name."
  type        = string
}
variable "environment" {
  description = "The environment for this deployment (e.g., dev, prod, staging)."
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}

# -------------------- Virtual Network Variables --------------------

variable "virtual_networks" {
  description = "Map of virtual networks to create."
  type = map(object({
    name                = string
    location            = string
    resource_group_name = string
    address_space       = list(string)
    subnets             = map(object({
      name           = string
      address_prefixes = list(string)
      delegations    = optional(list(object({
        name          = string
        service_name  = string
        actions       = list(string)
      })), [])
    }))
  }))
}

# -------------------- NSG Variables --------------------

variable "enable_nsg" {
  description = "If true, create NSGs."
  type        = bool
  default     = true
}

variable "nsgs" {
  description = "Map of NSGs to create."
  type = map(object({
    location            = string
    resource_group_name = string
  }))
  default = {}
}

variable "nsg_rules" {
  description = "Map of NSG rules to create."
  type = map(object({
    nsg_name                   = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = {}
}
# -------------------- Network Watcher Variables --------------------

# Toggle to enable or disable the network watcher
variable "enable_network_watcher" {
  description = "If true, create a network watcher for each virtual network."
  type        = bool
  default     = true
}

# -------------------- Storage Account Variables --------------------

# Toggle to create the storage account or not
variable "enable_flow_logs" {
  description = "If true, enable flow logs for all network watchers."
  type        = bool
  default     = true
}

# Tags to apply to all resources
variable "tags" {
  description = "A map of tags to apply to resources."
  type        = map(string)
  default     = {}
}

# -------------------- NSG Configurations --------------------

# Map of NSG configurations used by the flow logs
variable "nsg_configs" {
  description = "Map of NSGs and their configurations."
  type = map(object({
    vnet_name = string  # Name of the associated virtual network
  }))
  default = {}
}

# -------------------- Flow Log and Traffic Analytics Variables --------------------

# Number of days to retain flow log data
variable "log_retention_days" {
  description = "Number of days to retain flow log data."
  type        = number
  default     = 30
}
variable "enable_log_analytics" {
  description = "If true, create a Log Analytics Workspace."
  type        = bool
  default     = false
}

variable "log_analytics_sku" {
  description = "The SKU of the Log Analytics Workspace (e.g., 'PerGB2018')."
  type        = string
  default     = "PerGB2018"
}
# Toggle for enabling traffic analytics
variable "enable_traffic_analytics" {
  description = "If true, enable traffic analytics for flow logs."
  type        = bool
  default     = true
}

# Log Analytics Workspace details for traffic analytics
variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace to send traffic analytics data."
  type        = string
}

variable "log_analytics_workspace_region" {
  description = "The region of the Log Analytics workspace."
  type        = string
}

variable "log_analytics_workspace_resource_id" {
  description = "The resource ID of the Log Analytics workspace."
  type        = string
}

variable "traffic_analytics_interval" {
  description = "The interval in minutes for traffic analytics data collection."
  type        = number
  default     = 10
}