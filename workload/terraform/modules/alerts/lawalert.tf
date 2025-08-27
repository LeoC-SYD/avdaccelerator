module "avdi" {
  source                                                      = "../insights"
  resource_group_name                                         = var.resource_group_name
  name                                                        = var.name
  monitor_data_collection_rule_data_flow                      = var.monitor_data_collection_rule_data_flow
  monitor_data_collection_rule_name                           = var.monitor_data_collection_rule_name
  monitor_data_collection_rule_resource_group_name            = var.monitor_data_collection_rule_resource_group_name
  monitor_data_collection_rule_location                       = var.monitor_data_collection_rule_location
  target_resource_id                                          = var.target_resource_id
  monitor_data_collection_rule_association_target_resource_id = var.monitor_data_collection_rule_association_target_resource_id
  monitor_data_collection_rule_destinations                   = var.monitor_data_collection_rule_destinations
}

data "azurerm_log_analytics_workspace" "lawksp" {
  name                = lower(replace("log-avd-${substr(var.avdLocation, 0, 5)}-${var.prefix}", "-", ""))
  resource_group_name = "rg-avd-${substr(var.avdLocation, 0, 5)}-${var.prefix}-${var.rg_avdi}"

  depends_on = [
    module.avdi
  ]
}

//  target_resource_type     = "microsoft.desktopvirtualization/hostpools"

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "alert_v2" {
  provider            = azurerm.spoke
  name                = "Unhealthy VM"
  resource_group_name = azurerm_resource_group.rg_shared_name.name
  location            = var.avdLocation

  evaluation_frequency = "PT5M"
  window_duration      = "PT5M"
  scopes               = [data.azurerm_log_analytics_workspace.lawksp.id]
  severity             = 4

  criteria {
    query = <<-QUERY
       WVDAgentHealthStatus 
        | where EndpointState <> "Healthy" 
    QUERY

    time_aggregation_method = "Maximum"
    threshold               = 99.0
    operator                = "LessThan"

    resource_id_column    = "_ResourceId"
    metric_measure_column = "AggregatedValue"

    dimension {
      name     = "Computer"
      operator = "Include"
      values   = ["*"]
    }

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  auto_mitigation_enabled          = false
  workspace_alerts_storage_enabled = false
  description                      = "This is V2 custom log alert"
  display_name                     = "Unhealthy VM"
  enabled                          = true
  query_time_range_override        = "P2D"
  skip_query_validation            = false


}