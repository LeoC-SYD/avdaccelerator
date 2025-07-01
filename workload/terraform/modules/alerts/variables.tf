variable "hub_subscription_id" {
  type        = string
  description = "Hub Subscription id"
}

variable "rg_shared_name" {
  type        = string
  description = "Resource Group to share alerts with"
}

variable "avdLocation" {
  description = "Location of the resource group."
}

variable "spoke_subscription_id" {
  type        = string
  description = "Spoke Subscription id"
}

variable "prefix" {
  type        = string
  description = "Prefix of the name under 5 characters"
  validation {
    condition     = length(var.prefix) < 5 && lower(var.prefix) == var.prefix
    error_message = "The prefix value must be lowercase and < 4 chars."
  }
}

variable "rg_avdi" {
  type        = string
  description = "Name of the Resource group in which to deploy avd service objects"
}

variable "email_address" {
  type        = string
  description = "Email address to send alerts to"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group where the alerts will be deployed"
}

variable "name" {
  type        = string
  description = "Name of the AVD Insights resource"
}

variable "monitor_data_collection_rule_data_flow" {
  type        = string
  description = "Data flow configuration for the monitor data collection rule"
}

variable "monitor_data_collection_rule_name" {
  type        = string
  description = "Name of the monitor data collection rule"
}

variable "monitor_data_collection_rule_resource_group_name" {
  type        = string
  description = "Resource group name for the monitor data collection rule"
}

variable "monitor_data_collection_rule_location" {
  type        = string
  description = "Location of the monitor data collection rule"
}

variable "target_resource_id" {
  type        = string
  description = "Target resource ID for the monitor data collection rule association"
}

variable "monitor_data_collection_rule_association_target_resource_id" {
  type        = string
  description = "Target resource ID for the monitor data collection rule association"
}

variable "monitor_data_collection_rule_destinations" {
  type        = map(string)
  description = "Destinations for the monitor data collection rule"
}

variable "monitor_data_collection_rule_data_flow" {
  type        = string
  description = "Data flow for the monitor data collection rule"
  
}