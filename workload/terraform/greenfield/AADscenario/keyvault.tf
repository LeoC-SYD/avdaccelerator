module "avm-res-keyvault-vault" {
  source                      = "Azure/avm-res-keyvault-vault/azurerm"
  version                     = "0.5.3"
  location                    = azurerm_resource_group.this.location
  name                        = local.keyvault_name
  resource_group_name         = azurerm_resource_group.this.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  enabled_for_deployment      = true
  enabled_for_disk_encryption = true
  purge_protection_enabled    = true
  soft_delete_retention_days  = 7
  tags                        = local.tags
  diagnostic_settings = {
    to_la = {
      name                  = "to-la"
      workspace_resource_id = module.avm_res_operationalinsights_workspace.resource.id
    }
  }

  public_network_access_enabled = true
  private_endpoints = {
    primary = {
      private_dns_zone_resource_ids = [data.azurerm_private_dns_zone.pe-vaultdns-zone.id]
      subnet_resource_id            = data.azurerm_subnet.pesubnet.id
    }
  }

  network_acls = {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = ["136.28.83.128", "90.115.63.18", "92.92.163.27"]
    virtual_network_subnet_ids = [
      data.azurerm_subnet.pesubnet.id
    ]
  }
  
  # Les clés seront créées séparément après le délai de propagation RBAC
  keys = {}
}

# Generate VM local password
resource "random_password" "vmpass" {
  length  = 20
  special = true
}

# Create Key Vault Secret
resource "azurerm_key_vault_secret" "localpassword" {
  key_vault_id = module.avm-res-keyvault-vault.resource.id
  name         = "vmlocalpassword"
  value        = random_password.vmpass.result
  content_type = "Password"

  depends_on = [
    time_sleep.wait_for_rbac_propagation
  ]

  lifecycle {
    ignore_changes = [tags]
  }
}

# Sets RBAC permission for Key Vault
resource "azurerm_role_assignment" "keystor" {
  principal_id         = data.azurerm_client_config.current.object_id
  scope                = module.avm-res-keyvault-vault.resource.id
  role_definition_name = "Key Vault Administrator"
}

# Délai d'attente pour la propagation des permissions RBAC
resource "time_sleep" "wait_for_rbac_propagation" {
  depends_on      = [azurerm_role_assignment.keystor]
  create_duration = "90s"
}

# Créer la clé CMK pour le compte de stockage après la propagation RBAC
resource "azurerm_key_vault_key" "cmk_for_storage_account" {
  depends_on   = [time_sleep.wait_for_rbac_propagation]
  name         = "cmk-for-storage-account"
  key_vault_id = module.avm-res-keyvault-vault.resource.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey"
  ]
}
