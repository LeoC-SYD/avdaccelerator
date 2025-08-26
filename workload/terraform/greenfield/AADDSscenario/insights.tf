resource "azurerm_log_analytics_workspace" "law" {
  name                = lower(replace("law-avd-${var.prefix}", "-", ""))
  location            = azurerm_resource_group.rg_avdi.location
  resource_group_name = azurerm_resource_group.rg_avdi.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.tags
}
