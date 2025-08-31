module "session_hosts" {
  source               = "../../modules/session-hosts"
  prefix               = var.prefix
  vm_count             = var.rdsh_count
  location             = azurerm_resource_group.shrg.location
  resource_group_name  = azurerm_resource_group.shrg.name
  subnet_id            = data.azurerm_subnet.subnet.id
  session_host_sku     = var.session_host_sku
  local_admin_username = var.local_admin_username
  local_admin_password = azurerm_key_vault_secret.localpassword.value
  image_reference      = var.image_reference
  join_method          = var.join_method
  device_management    = var.device_management
  aadds_domain_name    = var.aadds_domain_name
  ou_path              = var.ou_path
  domain_join_upn      = local.join_upn
  domain_join_password = local.domain_join_creds != null ? local.domain_join_creds.password : null
  hostpool_name        = azurerm_virtual_desktop_host_pool.hostpool.name
  registration_token   = local.registration_token
  la_workspace_id      = azurerm_log_analytics_workspace.lawksp.workspace_id
  la_workspace_key     = azurerm_log_analytics_workspace.lawksp.primary_shared_key
  tags                 = local.tags
}
