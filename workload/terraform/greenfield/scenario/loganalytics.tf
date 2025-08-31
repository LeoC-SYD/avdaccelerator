resource "azurerm_log_analytics_workspace" "lawksp" {
  name                = lower(replace("law-avd-${var.prefix}", "-", ""))
  location            = azurerm_resource_group.avdirg.location
  resource_group_name = azurerm_resource_group.avdirg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.tags
}
