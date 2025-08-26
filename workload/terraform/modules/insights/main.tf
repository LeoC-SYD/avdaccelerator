resource "azurerm_monitor_data_collection_rule" "this" {
  name                = var.monitor_data_collection_rule_name
  location            = var.monitor_data_collection_rule_location
  resource_group_name = var.monitor_data_collection_rule_resource_group_name

  data_flow {
    streams      = var.monitor_data_collection_rule_data_flow[0].streams
    destinations = var.monitor_data_collection_rule_data_flow[0].destinations
  }

  destinations {
    log_analytics {
      name                  = var.monitor_data_collection_rule_destinations.log_analytics.name
      workspace_resource_id = var.monitor_data_collection_rule_destinations.log_analytics.workspace_resource_id
    }
  }

  tags = var.monitor_data_collection_rule_tags
}

resource "azurerm_monitor_data_collection_rule_association" "this" {
  name                    = var.name
  target_resource_id      = var.target_resource_id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.this.id
  description             = var.monitor_data_collection_rule_description
}
