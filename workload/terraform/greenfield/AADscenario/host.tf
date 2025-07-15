resource "time_rotating" "avd_token" {
  rotation_days = 1
}

resource "random_string" "AVD_local_password" {
  count            = var.rdsh_count
  length           = 16
  special          = true
  min_special      = 2
  override_special = "*!@#?"
}


resource "azurerm_network_interface" "avd_vm_nic" {
  count                          = var.rdsh_count
  name                           = "${var.prefix}-${count.index + 1}-nic"
  resource_group_name            = azurerm_resource_group.shrg.name
  location                       = azurerm_resource_group.shrg.location

  ip_configuration {
    name                          = "nic${count.index + 1}_config"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  lifecycle {
    create_before_destroy = true
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
  
  # encryption_at_host_enabled = true //'Microsoft.Compute/EncryptionAtHost' feature is must be enabled in the subscription for this setting to work https://learn.microsoft.com/en-us/azure/virtual-machines/disks-enable-host-based-encryption-portal?tabs=azure-powershell

  os_disk {
    name                 = "${lower(var.prefix)}-${count.index + 1}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  # To use marketplace image, uncomment the following lines and comment the source_image_id line
  source_image_reference {
    offer     = var.offer
    publisher = var.publisher
    sku       = var.sku
    version   = "latest"
  }
  
  identity {
    type = "SystemAssigned"
  }
  
  depends_on = [
    azurerm_network_interface.avd_vm_nic,
    azurerm_resource_group.shrg,
    azurerm_resource_group.rg
  ]
}

# S'assurer que la VM est démarrée avant d'installer les extensions

# Extension simple pour vérifier que la VM est prête pour les autres extensions
# resource "azurerm_virtual_machine_extension" "vm_startup" {
#   count                      = var.rdsh_count
#   name                       = "${var.prefix}-${count.index + 1}-startup-${formatdate("YYYYMMDDhhmmss", timestamp())}"
#   virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
#   publisher                  = "Microsoft.Compute"
#   type                       = "CustomScriptExtension"
#   type_handler_version       = "1.10"
#   auto_upgrade_minor_version = true
  
#   settings = <<SETTINGS
#     {
#       "commandToExecute": "powershell.exe -Command \"Write-Host 'VM is ready for extensions'\""
#     }
#   SETTINGS
  
#   timeouts {
#     create = "15m"
#     delete = "15m"
#   }
  
#   depends_on = [
#     azurerm_windows_virtual_machine.avd_vm
#   ]
# }

resource "azurerm_virtual_machine_extension" "aadjoin" {
  count                      = var.rdsh_count
  name                       = "${var.prefix}-${count.index + 1}-aadJoin"
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "2.0"
  auto_upgrade_minor_version = true
  
  timeouts {
    create = "30m"
    delete = "30m"
  }
  
  lifecycle {
    ignore_changes = [
      name
    ]
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

# Délai supplémentaire après AADJoin pour éviter les conflits d'opérations
resource "time_sleep" "wait_after_aad_join" {
  count = var.rdsh_count
  depends_on = [
    azurerm_virtual_machine_extension.aadjoin
  ]
  create_duration = "90s"
}

# Virtual Machine Extension for AVD Agent
resource "azurerm_virtual_machine_extension" "vmext_dsc" {
  count = var.rdsh_count

  name                       = "${var.prefix}${count.index + 1}-avd_dsc"
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.73"
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  auto_upgrade_minor_version = true
  
  lifecycle {
    ignore_changes = [
      name
    ]
  }
  
  protected_settings         = <<PROTECTED_SETTINGS
  {
    "properties": {
      "registrationInfoToken": "${azurerm_virtual_desktop_host_pool_registration_info.registrationinfo.token}"
    }
  }
PROTECTED_SETTINGS
  settings                   = <<-SETTINGS
    {
      "modulesUrl": "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_1.0.02990.697.zip",
      "configurationFunction": "Configuration.ps1\\AddSessionHost",
      "properties": {
        "HostPoolName":"${module.avm_res_desktopvirtualization_hostpool.resource.name}"
      }
    }
SETTINGS

  depends_on = [
    time_sleep.wait_after_aad_join,
    azurerm_virtual_desktop_host_pool_registration_info.registrationinfo
  ]
  
  timeouts {
    create = "30m"
    delete = "30m"
    update = "30m"
    read   = "5m"
  }
}

# Wait after DSC extension to prevent operation conflicts
resource "time_sleep" "wait_after_dsc" {
  count = var.rdsh_count
  depends_on = [
    azurerm_virtual_machine_extension.vmext_dsc
  ]
  create_duration = "60s"
}

# Virtual Machine Extension for AMA agent
resource "azurerm_virtual_machine_extension" "ama" {
  count = var.rdsh_count

  name                      = "AzureMonitorWindowsAgent"
  publisher                 = "Microsoft.Azure.Monitor"
  type                      = "AzureMonitorWindowsAgent"
  type_handler_version      = "1.22"
  virtual_machine_id        = azurerm_windows_virtual_machine.avd_vm[count.index].id
  automatic_upgrade_enabled = true
  
  lifecycle {
    ignore_changes = [
      name
    ]
  }
  
  depends_on = [
    time_sleep.wait_after_dsc
  ]
  
  timeouts {
    create = "30m"
    delete = "30m"
  }
}

# Wait after AMA extension to prevent operation conflicts
resource "time_sleep" "wait_after_ama" {
  count = var.rdsh_count
  depends_on = [
    azurerm_virtual_machine_extension.ama
  ]
  create_duration = "60s"
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

  lifecycle {
    ignore_changes = [
      name
    ]
  }

  depends_on = [
    time_sleep.wait_after_ama
  ]
}