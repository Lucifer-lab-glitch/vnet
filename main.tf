# -------------------- Provider Configuration --------------------
provider "azurerm" {
  features {}
}

# -------------------- Virtual Networks --------------------
resource "azurerm_virtual_network" "vnet" {
  for_each = var.virtual_networks

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  address_space       = each.value.address_space
  tags                = merge({ "environment" = var.environment, "project" = var.project }, var.tags)

  lifecycle {
    create_before_destroy = true
  }
}

# -------------------- Subnets --------------------
resource "azurerm_subnet" "subnets" {
  for_each             = { for vnet_name, vnet_config in var.virtual_networks : vnet_name => vnet_config.subnets }

  name                 = each.value.name
  virtual_network_name = azurerm_virtual_network.vnet[each.value.vnet_name].name
  resource_group_name  = azurerm_virtual_network.vnet[each.value.vnet_name].resource_group_name
  address_prefixes     = each.value.address_prefixes

  dynamic "delegation" {
    for_each = lookup(each.value, "delegations", [])
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_name
        actions = delegation.value.actions
      }
    }
  }
}

# -------------------- Network Security Group(NSG) -------------------
module "nsg_vm" {
  source              = "../../Modules/network_security_group_NSG"   # Path to the NSG module
  count               = var.enable_nsg ? 1 : 0  #  Only deploy NSG when enabled

  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = merge({ "environment" = var.environment, "project" = var.project }, var.tags)

  nsgs = var.enable_nsg ? {
    "vm-nsg" = {
      location            = var.location
      resource_group_name = var.resource_group_name
    }
  } : {}

  nsg_rules = var.enable_nsg ? [
    {
      nsg_name               = "vm-nsg"
      name                   = "Allow-SSH"
      priority               = 100
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "Tcp"
      source_port_range      = "*"
      destination_port_range = "22"
      source_address_prefix  = "*"
      destination_address_prefix = "*"
    },
    {
      nsg_name               = "vm-nsg"
      name                   = "Allow-HTTP"
      priority               = 110
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "Tcp"
      source_port_range      = "*"
      destination_port_range = "80"
      source_address_prefix  = "*"
      destination_address_prefix = "*"
    }
  ] : []
}

# -------------------- Network Watcher --------------------
resource "azurerm_network_watcher" "network_watcher" {
  for_each = var.enable_network_watcher ? { 
    for vnet_name, vnet_config in var.virtual_networks : 
    vnet_name => vnet_config.location 
  } : {}

  name                = "${each.key}-network-watcher"
  location            = each.value
  resource_group_name = azurerm_virtual_network.vnet[each.key].resource_group_name
}

# -------------------- Storage Account for Flow Logs --------------------
resource "azurerm_storage_account" "flowlog_storage" {
  count                     = var.enable_flow_logs ? 1 : 0
  name                      = var.enable_flow_logs ? "flowlogstorage${random_string.suffix.result}" : ""
  location                  = var.location
  resource_group_name       = var.resource_group_name
  account_tier              = "Standard"
  account_replication_type  = "LRS"

  tags = merge({ "environment" = var.environment, "project" = var.project }, var.tags)
}

resource "random_string" "suffix" {
  count  = var.enable_flow_logs ? 1 : 0
  length = 6
  special = false
  upper = false
}

# -------------------- log_analytics_workspace --------------------
resource "azurerm_log_analytics_workspace" "log_analytics" {
  count                = var.enable_log_analytics ? 1 : 0
  name                 = var.enable_log_analytics ? "${var.environment}-law" : ""
  location             = var.location
  resource_group_name  = var.resource_group_name
  sku                  = var.log_analytics_sku
  retention_in_days    = var.log_retention_days
  tags                 = var.tags
}

# -------------------- Network Watcher Flow Logs --------------------
resource "azurerm_network_watcher_flow_log" "flow_logs" {
  for_each = var.enable_flow_logs ? { 
    for nsg_name, nsg_config in var.nsg_configs : 
    nsg_name => nsg_config 
    if var.enable_flow_logs 
  } : {}

  network_watcher_name = azurerm_network_watcher.network_watcher[each.value.vnet_name].name
  resource_group_name  = azurerm_virtual_network.vnet[each.value.vnet_name].resource_group_name
  name                 = "${each.key}-flow-log"

  target_resource_id   = azurerm_network_security_group.nsg[each.key].id
  storage_account_id   = azurerm_storage_account.flowlog_storage[0].id
  enabled              = true

  retention_policy {
    enabled = true
    days    = var.log_retention_days
  }

  traffic_analytics {
    enabled               = var.enable_traffic_analytics
    workspace_id          = var.log_analytics_workspace_id
    workspace_region      = var.log_analytics_workspace_region
    workspace_resource_id = var.log_analytics_workspace_resource_id
    interval_in_minutes   = var.traffic_analytics_interval
  }
}
