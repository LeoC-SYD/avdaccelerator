locals {
  keyvault_name      = lower("kv-avd-${var.prefix}-${random_string.random.id}")
  storage_name       = lower(replace("stavd${var.prefix}${random_string.random.id}", "-", ""))
  allow_list_ip      = var.allow_list_ip
  white_list_ip      = ["0.0.0.0"]
  registration_token = azurerm_virtual_desktop_host_pool_registration_info.registrationinfo.token
  join_username      = coalesce(var.aadds_username, var.dc_admin_username)
  join_password      = var.aadds_password != null ? var.aadds_password : random_password.dc_admin[0].result
  join_upn           = "${local.join_username}@${var.aadds_domain_name}"
  tags = {
    environment        = var.prefix
    source             = "https://github.com/Azure/avdaccelerator/tree/main/workload/terraform/avdbaseline"
    cm-resource-parent = azurerm_virtual_desktop_host_pool.hostpool.id
  }
    rdp_kv = {
    # redirections / UX
    "drivestoredirect:s"        = "*"
    "audiomode:i"               = 0
    "videoplaybackmode:i"       = 1
    "redirectclipboard:i"       = 1
    "redirectprinters:i"        = 1
    "devicestoredirect:s"       = "*"
    "redirectcomports:i"        = 1
    "redirectsmartcards:i"      = 1
    "usbdevicestoredirect:s"    = "*"
    "autoreconnection enabled:i"= 1

    # security / protocol
    "enablecredsspsupport:i"    = 1

    # platform (hosts AAD DS -> **disable** AAD auth)
    "targetisaadjoined:i"       = 0
    "enablerdsaadauth:i"        = 0

    # AAD DS: force the domain context to avoid the AzureAD provider
    "domain:s"                  = var.aadds_netbios_domain
    }

    # optional: WebAuthn redirection
    rdp_webauthn = var.enable_webauthn ? { "redirectwebauthn:i" = 1 } : {}

    # string construction
    custom_rdp_properties = join(";", [
    for k, v in merge(local.rdp_kv, local.rdp_webauthn) : "${k}:${v}"
    ])
  }
