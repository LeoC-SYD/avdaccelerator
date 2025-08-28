
resource "azurerm_network_interface" "avd_vm_nic" {
  count               = var.rdsh_count
  name                = "${var.prefix}-${count.index + 1}-nic"
  resource_group_name = azurerm_resource_group.shrg.name
  location            = azurerm_resource_group.shrg.location

  ip_configuration {
    name                          = "nic${count.index + 1}_config"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }


  depends_on = [
    azurerm_resource_group.shrg
  ]
}

resource "azurerm_windows_virtual_machine" "avd_vm" {
  count                      = var.rdsh_count
  name                       = "avd-vm-${var.prefix}-${count.index + 1}"
  resource_group_name        = azurerm_resource_group.shrg.name
  location                   = azurerm_resource_group.shrg.location
  size                       = var.vm_size
  network_interface_ids      = ["${azurerm_network_interface.avd_vm_nic.*.id[count.index]}"]
  provision_vm_agent         = true
  admin_username             = var.local_admin_username
  admin_password             = azurerm_key_vault_secret.localpassword.value
  encryption_at_host_enabled = false //'Microsoft.Compute/EncryptionAtHost' feature is must be enabled in the subscription for this setting to work https://learn.microsoft.com/en-us/azure/virtual-machines/disks-enable-host-based-encryption-portal?tabs=azure-powershell

  os_disk {
    name                 = "${lower(var.prefix)}-${count.index + 1}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer = "windows-11"
    sku = "win11-24h2-avd"
    version = "26100.3476.250306"
  }
  # source_image_id = "/subscriptions/${var.avdshared_subscription_id}/resourceGroups/${var.image_rg}/providers/Microsoft.Compute/galleries/${var.gallery_name}/images/${var.image_name}/versions/latest"
  depends_on = [
    azurerm_resource_group.shrg,
    azurerm_network_interface.avd_vm_nic,
    azurerm_resource_group.rg,
    azurerm_virtual_desktop_host_pool.hostpool
  ]
  identity {
    type = "SystemAssigned"
  }
}

resource "random_password" "dc_admin" {
  count   = var.aadds_password == null ? 1 : 0
  length  = 16
  special = true
}

resource "azuread_user" "dc_admin" {
  count                 = var.aadds_username == null ? 1 : 0
  user_principal_name   = local.join_upn
  display_name          = "AADDS Join Account"
  password              = local.join_password
  force_password_change = false
}

resource "azurerm_virtual_machine_extension" "aaddsjoin" {
  count                      = var.rdsh_count
  name                       = "${var.prefix}-${count.index + 1}-aaddsJoin"
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  publisher                  = "Microsoft.Compute"
  type                       = "JsonADDomainExtension"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = true

  settings = <<-SETTINGS
    {
      "Name": "${var.aadds_domain_name}",
      "OUPath": "${var.ou_path}",
      "User": "${local.join_upn}",
      "Restart": "true",
      "Options": "3"
    }
    SETTINGS

  protected_settings = <<-PROTECTED_SETTINGS
    {
      "Password": "${local.join_password}"
    }
    PROTECTED_SETTINGS

  lifecycle {
    ignore_changes = [settings, protected_settings]
  }

  /*
# Uncomment out settings for Intune
  settings = <<SETTINGS

     {
        "mdmId" : "0000000a-0000-0000-c000-000000000000"
      }
SETTINGS
*/
}

resource "azurerm_virtual_machine_extension" "vmext_dsc" {
  count                      = var.rdsh_count
  name                       = "${var.prefix}${count.index + 1}-avd_dsc"
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.73"
  auto_upgrade_minor_version = true

  settings = <<-SETTINGS
    {
      "modulesUrl": "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_09-08-2022.zip",
      "configurationFunction": "Configuration.ps1\\AddSessionHost",
      "properties": {
        "HostPoolName":"${azurerm_virtual_desktop_host_pool.hostpool.name}"
      }
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
    "properties": {
      "registrationInfoToken": "${local.registration_token}"
    }
  }
PROTECTED_SETTINGS

  depends_on = [
    azurerm_virtual_machine_extension.aaddsjoin,
    azurerm_virtual_desktop_host_pool.hostpool,
    azurerm_log_analytics_workspace.lawksp
  ]
}

# MMA agent
resource "azurerm_virtual_machine_extension" "mma" {
  name                       = "MicrosoftMonitoringAgent"
  count                      = var.rdsh_count
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = "MicrosoftMonitoringAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  settings                   = <<SETTINGS
    {
      "workspaceId": "${azurerm_log_analytics_workspace.lawksp.workspace_id}"
    }
      SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
   "workspaceKey": "${azurerm_log_analytics_workspace.lawksp.primary_shared_key}"
  }
PROTECTED_SETTINGS

  depends_on = [
    azurerm_virtual_machine_extension.aaddsjoin,
    azurerm_virtual_machine_extension.vmext_dsc,
    azurerm_log_analytics_workspace.lawksp
  ]
}

# Microsoft Antimalware
resource "azurerm_virtual_machine_extension" "mal" {
  name                       = "IaaSAntimalware"
  count                      = var.rdsh_count
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  publisher                  = "Microsoft.Azure.Security"
  type                       = "IaaSAntimalware"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = "true"

  depends_on = [
    azurerm_virtual_machine_extension.aaddsjoin,
    azurerm_virtual_machine_extension.vmext_dsc,
    azurerm_virtual_machine_extension.mma
  ]

  lifecycle {

  }
}
