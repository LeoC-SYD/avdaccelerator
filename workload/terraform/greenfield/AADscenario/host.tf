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
  
  # Add a lifecycle block to ensure this is deleted before the host pool
  lifecycle {
    create_before_destroy = true
  }
}


resource "azurerm_virtual_machine_extension" "aadjoin" {
  count                      = var.rdsh_count
  name                       = "aadjoin"
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
      name,
      settings,
      protected_settings,
      tags
    ]
  }
  
# Uncomment out settings for Intune
  settings = <<SETTINGS

     {
        "mdmId" : "0000000a-0000-0000-c000-000000000000"
      }
SETTINGS
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

  name                       = "avd_dsc"
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.73"
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  auto_upgrade_minor_version = true
  
  lifecycle {
    ignore_changes = [
      name,
      settings,
      protected_settings,
      tags
    ]
    # Ajout de cette directive pour garantir la suppression des VMs avant le host pool
    create_before_destroy = true
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

  # Le DSC a besoin de l'enregistrement du host pool mais nous devons éviter les cycles
  # En gardant uniquement la dépendance sur time_sleep.wait_after_aad_join
  depends_on = [
    time_sleep.wait_after_aad_join
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

  name                      = "ama"
  publisher                 = "Microsoft.Azure.Monitor"
  type                      = "AzureMonitorWindowsAgent"
  type_handler_version      = "1.22"
  virtual_machine_id        = azurerm_windows_virtual_machine.avd_vm[count.index].id
  automatic_upgrade_enabled = true
  
  lifecycle {
    ignore_changes = [
      name,
      settings,
      protected_settings,
      tags
    ]
    create_before_destroy = true
  }
  
  # Supprimer la dépendance sur time_sleep.wait_after_dsc pour éviter les cycles
  depends_on = [
    azurerm_windows_virtual_machine.avd_vm
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
  name                       = "antimalware"
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
    # Add this to help with deletion order
    create_before_destroy = true
  }

  # Supprimer la dépendance sur time_sleep.wait_after_ama pour éviter les cycles
  depends_on = [
    azurerm_windows_virtual_machine.avd_vm
  ]
}