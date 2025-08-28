locals {
  kv_name       = lower("kv-avd-${var.prefix}-${random_string.random.id}")
  allow_list_ip = var.allow_list_ip
    tags = {
    environment        = var.prefix
    source             = "https://github.com/Azure/avdaccelerator/tree/main/workload/terraform/avdbaseline"
    cm-resource-parent = azurerm_virtual_desktop_host_pool.hostpool.id
  }
}