moved {
  from = azurerm_network_interface.avd_vm_nic
  to   = module.session_hosts.azurerm_network_interface.this
}

moved {
  from = azurerm_windows_virtual_machine.avd_vm
  to   = module.session_hosts.azurerm_windows_virtual_machine.this
}

moved {
  from = azurerm_virtual_machine_extension.aaddsjoin
  to   = module.session_hosts.azurerm_virtual_machine_extension.domain_join
}

moved {
  from = azurerm_virtual_machine_extension.vmext_dsc
  to   = module.session_hosts.azurerm_virtual_machine_extension.dsc
}

moved {
  from = azurerm_virtual_machine_extension.mma
  to   = module.session_hosts.azurerm_virtual_machine_extension.mma
}
