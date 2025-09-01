# Creates Azure Virtual Desktop Insights Log Analytics Workspace
module "dcr" {
  source                                           = "../../modules/insights"
  name                                             = "avddcr1"
  monitor_data_collection_rule_resource_group_name = azurerm_resource_group.rg.name
  # DCR must be in the same region as the target VMs; align with host RG location
  monitor_data_collection_rule_location = azurerm_resource_group.shrg.location
  monitor_data_collection_rule_name     = "microsoft-avdi-${var.avdLocation}"
  monitor_data_collection_rule_data_flow = [
    {
      destinations = [azurerm_log_analytics_workspace.lawksp.name]
      streams      = ["Microsoft-Perf", "Microsoft-Event"]
    }
  ]
  monitor_data_collection_rule_destinations = {
    log_analytics = {
      name                  = azurerm_log_analytics_workspace.lawksp.name
      workspace_resource_id = azurerm_log_analytics_workspace.lawksp.id
    }
  }
  target_resource_id = element(values(module.session_hosts.session_host_ids), 0)
  depends_on         = [azurerm_log_analytics_workspace.lawksp]
}

# Creates the Azure Virtual Desktop Spoke Network resources
module "network" {
  source = "../../modules/network"
  # Allow network resources to be placed in a different region
  avdLocation              = coalesce(var.network_location, var.avdLocation)
  rg_network               = var.rg_network
  vnet                     = var.vnet
  snet                     = var.snet
  pesnet                   = var.pesnet
  vnet_range               = var.vnet_range
  dns_servers              = var.dns_servers
  nsg                      = "${var.nsg}-${substr(var.avdLocation, 0, 5)}-${var.prefix}"
  prefix                   = var.prefix
  rt                       = "${var.rt}-${substr(var.avdLocation, 0, 5)}-${var.prefix}"
  hub_connectivity_rg      = var.hub_connectivity_rg
  hub_vnet                 = var.hub_vnet
  subnet_range             = var.subnet_range
  pesubnet_range           = var.pesubnet_range
  next_hop_ip              = var.next_hop_ip
  fw_policy                = var.fw_policy
  hub_subscription_id      = var.hub_subscription_id
  spoke_subscription_id    = var.spoke_subscription_id
  identity_subscription_id = var.identity_subscription_id
  identity_rg              = var.identity_rg
  identity_vnet            = var.identity_vnet
}
