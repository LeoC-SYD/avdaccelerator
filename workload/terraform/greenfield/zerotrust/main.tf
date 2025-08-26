# Creates Azure Virtual Desktop Insights Log Analytics Workspace
module "dcr" {
  source                                                      = "../../modules/insights"
  name                                                        = "avddcr1"
  monitor_data_collection_rule_resource_group_name            = azurerm_resource_group.rg.name
  monitor_data_collection_rule_location                       = azurerm_resource_group.rg.location
  monitor_data_collection_rule_name                           = "microsoft-avdi-${var.avdLocation}"
  monitor_data_collection_rule_association_target_resource_id = azurerm_windows_virtual_machine.avd_vm[0].id
  monitor_data_collection_rule_data_flow = [
    {
      destinations = [data.azurerm_log_analytics_workspace.lawksp.name]
      streams      = ["Microsoft-Perf", "Microsoft-Event"]
    }
  ]
  monitor_data_collection_rule_destinations = {
    log_analytics = {
      name                  = data.azurerm_log_analytics_workspace.lawksp.name
      workspace_resource_id = data.azurerm_log_analytics_workspace.lawksp.id
    }
  }
  resource_group_name = azurerm_resource_group.rg.name
  target_resource_id  = azurerm_windows_virtual_machine.avd_vm[0].id
}

# Creates the Azure Virtual Desktop Spoke Network resources
module "network" {
  source                   = "../../modules/network"
  avdLocation              = var.avdLocation
  rg_network               = var.rg_network
  vnet                     = var.vnet
  snet                     = var.snet
  pesnet                   = var.pesnet
  vnet_range               = var.vnet_range
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



# Optional - creates AVD hostpool, remote application group, and workspace for remote apps
# Uncomment out if needed - this is a separate module from the desktop one above
# Remove /* at beginning and */ at the end to uncomment out the entire module
/*
module "poolremoteapp" {
  source         = "../../modules/poolremoteapp"
  ragworkspace   = "${var.ragworkspace}-${substr(var.avdLocation,0,5)}-${var.prefix}-remote"  //var.ragworkspace
  raghostpool    = "${var.raghostpool}-${substr(var.avdLocation,0,5)}-${var.prefix}-poolremoteapp" //var.raghostpool
  rag            = "${var.rag}-${substr(var.avdLocation,0,5)}-${var.prefix}" //var.rag
  rg_so          = var.rg_so
  avdLocation    = var.avdLocation
  rg_shared_name = var.rg_shared_name
  prefix         = var.prefix
  rfc3339        = var.rfc3339
  depends_on     = [module.dcr]
}
*/

# Optional - creates AVD personal hostpool, desktop application group, and workspace for personal desktops
# Uncomment out if needed - this is a separate module from the desktop one above
# Remove /* at beginning and */ at the end to uncomment out the entire module
/*
module "personal" {
  source         = "../../modules/personal"
  personalpool   = "${var.personalpool}-${substr(var.avdLocation,0,5)}-${var.prefix}-personal" //var.personalpool
  pworkspace     = "${var.pworkspace}-${substr(var.avdLocation,0,5)}-${var.prefix}-personal" //var.pworkspace
  rg_so          = var.rg_so
  avdLocation    = var.avdLocation
  rg_shared_name = var.rg_shared_name
  prefix         = var.prefix
  rfc3339        = var.rfc3339
  pag            = "${var.pag}-${substr(var.avdLocation,0,5)}-${var.prefix}" //var.pag
  depends_on     = [module.dcr]
}
*/
