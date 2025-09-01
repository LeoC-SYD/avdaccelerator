variable "prefix" {
  type = string
}

variable "vm_count" {
  type = number
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "session_host_sku" {
  type = string
}

variable "local_admin_username" {
  type = string
}

variable "local_admin_password" {
  type      = string
  sensitive = true
}

variable "image_reference" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}

variable "join_method" {
  type = string
}

variable "device_management" {
  type    = string
  default = "none"
}

variable "aadds_domain_name" {
  type    = string
  default = null
}

variable "ou_path" {
  type    = string
  default = null
}

variable "domain_join_upn" {
  type    = string
  default = null
}

variable "domain_join_password" {
  type      = string
  default   = null
  sensitive = true
}

variable "hostpool_name" {
  type = string
}

variable "registration_token" {
  type      = string
  sensitive = true
}

variable "la_workspace_id" {
  type = string
}

variable "la_workspace_key" {
  type      = string
  sensitive = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
