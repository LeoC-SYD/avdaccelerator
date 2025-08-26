variable "monitor_data_collection_rule_name" {
  type        = string
  description = "Name of the Data Collection Rule"
}

variable "monitor_data_collection_rule_location" {
  type        = string
  description = "Azure region where the Data Collection Rule will be created"
}

variable "monitor_data_collection_rule_resource_group_name" {
  type        = string
  description = "Resource group for the Data Collection Rule"
}

variable "monitor_data_collection_rule_data_flow" {
  type = list(object({
    destinations = list(string)
    streams      = list(string)
  }))
  description = "Data flow configuration for the rule"
}

variable "monitor_data_collection_rule_destinations" {
  type = object({
    log_analytics = object({
      name                  = string
      workspace_resource_id = string
    })
  })
  description = "Destination configuration for the rule"
}

variable "monitor_data_collection_rule_tags" {
  type        = map(string)
  description = "Tags to apply to the Data Collection Rule"
  default     = {}
}

variable "name" {
  type        = string
  description = "Name of the Data Collection Rule Association"
}

variable "target_resource_id" {
  type        = string
  description = "ID of the resource to associate with the Data Collection Rule"
}

variable "monitor_data_collection_rule_description" {
  type        = string
  description = "Description for the Data Collection Rule Association"
  default     = null
}
