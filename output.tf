# Output the IDs of all Virtual Networks
output "vnet_ids" {
  description = "Map of VNet names to their IDs."
  value       = { for vnet_name, vnet in azurerm_virtual_network.vnet : vnet_name => vnet.id }
}

# Output the IDs of all Subnets
output "subnet_ids" {
  description = "Map of Subnet names to their IDs."
  value       = { for subnet_name, subnet in azurerm_subnet.subnets : subnet_name => subnet.id }
}

# Output the IDs of all NSGs
output "nsg_ids" {
  description = "Map of NSG names to their IDs."
  value       = module.nsg_vm.azurerm_network_security_group.nsg
}

# Output the name and ID of the Log Analytics Workspace
output "log_analytics_workspace" {
  description = "Details of the Log Analytics workspace."
  value       = var.enable_log_analytics ? {
    name = azurerm_log_analytics_workspace.log_analytics[0].name
    id   = azurerm_log_analytics_workspace.log_analytics[0].id
  } : null
}

# Output the names of Network Watchers
output "network_watcher_names" {
  description = "Names of the created Network Watchers."
  value       = { for watcher_name, watcher in azurerm_network_watcher.network_watcher : watcher_name => watcher.name }
}

# Output the storage account name for flow logs
output "flowlog_storage_account_name" {
  description = "The name of the storage account used for flow logs."
  value       = var.enable_flow_logs ? azurerm_storage_account.flowlog_storage[0].name : null
}

# Output the IDs of flow logs
output "flow_log_ids" {
  description = "Map of flow log names to their IDs."
  value       = var.enable_flow_logs ? { for flow_log_name, flow_log in azurerm_network_watcher_flow_log.flow_logs : flow_log_name => flow_log.id } : {}
}
