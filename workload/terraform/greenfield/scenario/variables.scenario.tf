variable "scenario_identity" {
  description = "Identity scenario: aadds, entra_id, or hybrid_ad"
  type        = string
  validation {
    condition     = contains(["aadds", "entra_id", "hybrid_ad"], var.scenario_identity)
    error_message = "scenario_identity must be one of aadds, entra_id, or hybrid_ad"
  }
}

variable "device_management" {
  description = "Device management option"
  type        = string
  default     = "none"
  validation {
    condition     = contains(["intune", "none"], var.device_management)
    error_message = "device_management must be intune or none"
  }
}

variable "fslogix_storage" {
  description = "FSLogix profile storage type"
  type        = string
  default     = "azure_files"
  validation {
    condition     = contains(["azure_files", "azure_netapp_files"], var.fslogix_storage)
    error_message = "fslogix_storage must be azure_files or azure_netapp_files"
  }
}

variable "fslogix_auth_mode" {
  description = "FSLogix authentication mode"
  type        = string
  default     = "aadds_smb"
  validation {
    condition     = contains(["aadds_smb", "entra_id_kerberos"], var.fslogix_auth_mode)
    error_message = "fslogix_auth_mode must be aadds_smb or entra_id_kerberos"
  }
}

variable "join_method" {
  description = "Join method for session hosts"
  type        = string
  validation {
    condition     = contains(["domain_join", "entra_join"], var.join_method)
    error_message = "join_method must be domain_join or entra_join"
  }
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "kv_id" {
  description = "Key Vault resource ID for secrets"
  type        = string
}

variable "la_workspace_id" {
  description = "Log Analytics workspace ID"
  type        = string
}

variable "image_reference" {
  description = "Session host image reference"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}

variable "vmss_capacity_min" {
  description = "Minimum number of session host instances"
  type        = number
  default     = 1
}

variable "vmss_capacity_max" {
  description = "Maximum number of session host instances"
  type        = number
  default     = 10
}

variable "scaling_plan" {
  description = "Scaling plan configuration"
  type = object({
    name     = string
    timezone = string
    schedules = list(object({
      name                                 = string
      days                                 = list(string)
      ramp_up_start_time                   = string
      ramp_up_load_balancing_algorithm     = string
      ramp_up_minimum_hosts                = number
      ramp_up_capacity_threshold_percent   = number
      peak_start_time                      = string
      peak_load_balancing_algorithm        = string
      ramp_down_start_time                 = string
      ramp_down_load_balancing_algorithm   = string
      ramp_down_minimum_hosts              = number
      ramp_down_capacity_threshold_percent = number
      ramp_down_force_logoff_users         = bool
      ramp_down_wait_time_minutes          = number
      ramp_down_notification_message       = string
    }))
  })
  default = null
}

variable "network" {
  description = "Network configuration"
  type = object({
    vnet_id = string
    subnets = map(string)
  })
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

check "entra_join_identity" {
  assert {
    condition     = var.join_method != "entra_join" || var.scenario_identity == "entra_id"
    error_message = "entra_join requires scenario_identity to be entra_id"
  }
}

check "entra_fslogix_identity" {
  assert {
    condition     = var.fslogix_auth_mode != "entra_id_kerberos" || var.scenario_identity == "entra_id"
    error_message = "fslogix_auth_mode entra_id_kerberos requires scenario_identity to be entra_id"
  }
}
