# Example Entra ID cloud-only scenario
scenario_identity = "entra_id"
device_management = "intune"
fslogix_storage   = "azure_files"
fslogix_auth_mode = "entra_id_kerberos"
join_method       = "entra_join"

tenant_id       = "00000000-0000-0000-0000-000000000000"
subscription_id = "00000000-0000-0000-0000-000000000000"
kv_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.KeyVault/vaults/kv"
la_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.OperationalInsights/workspaces/la"

prefix               = "test"
rdsh_count           = 2
session_host_sku     = "Standard_D8s_v5"
local_admin_username = "localadmin"

aadds_domain_name = null
ou_path           = null

image_reference = {
  publisher = "MicrosoftWindowsDesktop"
  offer     = "windows-11"
  sku       = "win11-24h2-avd"
  version   = "latest"
}

network = {
  vnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet"
  subnets = {
    avd = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/avd"
  }
}

tags = {
  environment = "dev"
}
