terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.100.0"
    }
  }
}

locals {
  instances          = { for i in range(var.vm_count) : format("%02d", i + 1) => {} }
  enable_domain_join = var.join_method == "domain_join"
  enable_aad_login   = var.join_method == "entra_join"
  enable_intune      = var.device_management == "intune"
}

resource "azurerm_network_interface" "this" {
  for_each            = local.instances
  name                = "${var.prefix}-${each.key}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "nic${each.key}_config"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

resource "azurerm_windows_virtual_machine" "this" {
  for_each              = local.instances
  name                  = "avd-vm-${var.prefix}-${each.key}"
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = var.session_host_sku
  admin_username        = var.local_admin_username
  admin_password        = var.local_admin_password
  network_interface_ids = [azurerm_network_interface.this[each.key].id]
  provision_vm_agent    = true

  os_disk {
    name                 = "${lower(var.prefix)}-${each.key}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.image_reference.publisher
    offer     = var.image_reference.offer
    sku       = var.image_reference.sku
    version   = var.image_reference.version
  }

  identity { type = "SystemAssigned" }
  tags = var.tags
}

resource "azurerm_virtual_machine_extension" "domain_join" {
  for_each                   = local.enable_domain_join ? azurerm_windows_virtual_machine.this : {}
  name                       = "${var.prefix}-${each.key}-domainjoin"
  virtual_machine_id         = each.value.id
  publisher                  = "Microsoft.Compute"
  type                       = "JsonADDomainExtension"
  type_handler_version       = "2.2"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    Name    = var.aadds_domain_name
    OUPath  = coalesce(var.ou_path, "")
    User    = var.domain_join_upn
    Restart = "true"
    Options = "3"
  })

  protected_settings = jsonencode({
    Password = var.domain_join_password
  })

  lifecycle {
    ignore_changes = [settings, protected_settings]
  }
}

resource "azurerm_virtual_machine_extension" "aad_login" {
  for_each                   = local.enable_aad_login ? azurerm_windows_virtual_machine.this : {}
  name                       = "${var.prefix}-${each.key}-aadlogin"
  virtual_machine_id         = each.value.id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
}

resource "azurerm_virtual_machine_extension" "intune" {
  for_each                   = local.enable_intune ? azurerm_windows_virtual_machine.this : {}
  name                       = "${var.prefix}-${each.key}-intune"
  virtual_machine_id         = each.value.id
  publisher                  = "Microsoft.Intune"
  type                       = "IntuneManagementExtension"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
}

resource "azurerm_virtual_machine_extension" "dsc" {
  for_each                   = azurerm_windows_virtual_machine.this
  name                       = "${var.prefix}-${each.key}-avd_dsc"
  virtual_machine_id         = each.value.id
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.73"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    modulesUrl            = "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_09-08-2022.zip"
    configurationFunction = "Configuration.ps1\\AddSessionHost"
    properties = {
      HostPoolName = var.hostpool_name
    }
  })

  protected_settings = jsonencode({
    properties = {
      registrationInfoToken = var.registration_token
    }
  })

  depends_on = [azurerm_virtual_machine_extension.domain_join, azurerm_virtual_machine_extension.aad_login]
}

resource "azurerm_virtual_machine_extension" "mma" {
  for_each                   = azurerm_windows_virtual_machine.this
  name                       = "MicrosoftMonitoringAgent"
  virtual_machine_id         = each.value.id
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = "MicrosoftMonitoringAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  settings = jsonencode({
    workspaceId = var.la_workspace_id
  })
  protected_settings = jsonencode({
    workspaceKey = var.la_workspace_key
  })
}

output "session_host_ids" {
  description = "IDs of created session hosts"
  value       = { for k, v in azurerm_windows_virtual_machine.this : k => v.id }
}
