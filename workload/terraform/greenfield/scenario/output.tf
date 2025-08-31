output "azure_virtual_desktop_compute_resource_group" {
  description = "Name of the Resource group in which to deploy session host"
  value       = azurerm_resource_group.rg.name
}

output "azure_virtual_desktop_host_pool" {
  description = "Name of the Azure Virtual Desktop host pool"
  value       = azurerm_virtual_desktop_host_pool.hostpool.name
}

output "azurerm_virtual_desktop_application_group" {
  description = "Name of the Azure Virtual Desktop DAG"
  value       = azurerm_virtual_desktop_application_group.dag.name
}

output "azurerm_virtual_desktop_workspace" {
  description = "Name of the Azure Virtual Desktop workspace"
  value       = azurerm_virtual_desktop_workspace.workspace.name
}

output "location" {
  description = "The Azure region"
  value       = azurerm_resource_group.rg.location
}

output "session_host_count" {
  description = "The number of VMs created"
  value       = var.rdsh_count
}

output "dnsservers" {
  description = "Custom DNS configuration"
  value       = data.azurerm_virtual_network.vnet.dns_servers
}

output "vnetrange" {
  description = "Address range for deployment vnet"
  value       = data.azurerm_virtual_network.vnet.address_space
}

output "AVD_user_groupname" {
  description = "Microsoft Entra ID Group for AVD users"
  value       = data.azuread_group.adds_group.display_name
}

output "scenario_identity" {
  description = "Deployed identity scenario"
  value       = var.scenario_identity
}

output "join_method" {
  description = "Session host join method"
  value       = var.join_method
}

output "fslogix_auth_mode" {
  description = "FSLogix authentication mode"
  value       = var.fslogix_auth_mode
}

output "session_host_ids" {
  description = "Session host VM resource IDs"
  value       = module.session_hosts.session_host_ids
}
