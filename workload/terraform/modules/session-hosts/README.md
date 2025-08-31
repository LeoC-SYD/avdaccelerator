# session-hosts module

Manages Azure Virtual Desktop session host virtual machines and related extensions. Supports multiple identity and device management scenarios.

## Usage

```hcl
module "session_hosts" {
  source              = "../modules/session-hosts"
  prefix              = "avd"
  vm_count            = 2
  location            = azurerm_resource_group.shrg.location
  resource_group_name = azurerm_resource_group.shrg.name
  subnet_id           = data.azurerm_subnet.subnet.id
  session_host_sku    = var.session_host_sku
  local_admin_username= var.local_admin_username
  local_admin_password= azurerm_key_vault_secret.localpassword.value
  image_reference     = var.image_reference
  join_method         = var.join_method
  device_management   = var.device_management
  aadds_domain_name   = var.aadds_domain_name
  domain_join_upn     = local.join_upn
  domain_join_password= local.domain_join_creds.password
  hostpool_name       = azurerm_virtual_desktop_host_pool.hostpool.name
  registration_token  = local.registration_token
  la_workspace_id     = azurerm_log_analytics_workspace.lawksp.workspace_id
  la_workspace_key    = azurerm_log_analytics_workspace.lawksp.primary_shared_key
  tags                = local.tags
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.100.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.100.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_network_interface.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_virtual_machine_extension.aad_login](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.domain_join](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.dsc](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.intune](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.mma](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_windows_virtual_machine.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aadds_domain_name"></a> [aadds\_domain\_name](#input\_aadds\_domain\_name) | n/a | `string` | `null` | no |
| <a name="input_device_management"></a> [device\_management](#input\_device\_management) | n/a | `string` | `"none"` | no |
| <a name="input_domain_join_password"></a> [domain\_join\_password](#input\_domain\_join\_password) | n/a | `string` | `null` | no |
| <a name="input_domain_join_upn"></a> [domain\_join\_upn](#input\_domain\_join\_upn) | n/a | `string` | `null` | no |
| <a name="input_hostpool_name"></a> [hostpool\_name](#input\_hostpool\_name) | n/a | `string` | n/a | yes |
| <a name="input_image_reference"></a> [image\_reference](#input\_image\_reference) | n/a | <pre>object({<br>    publisher = string<br>    offer     = string<br>    sku       = string<br>    version   = string<br>  })</pre> | n/a | yes |
| <a name="input_join_method"></a> [join\_method](#input\_join\_method) | n/a | `string` | n/a | yes |
| <a name="input_la_workspace_id"></a> [la\_workspace\_id](#input\_la\_workspace\_id) | n/a | `string` | n/a | yes |
| <a name="input_la_workspace_key"></a> [la\_workspace\_key](#input\_la\_workspace\_key) | n/a | `string` | n/a | yes |
| <a name="input_local_admin_password"></a> [local\_admin\_password](#input\_local\_admin\_password) | n/a | `string` | n/a | yes |
| <a name="input_local_admin_username"></a> [local\_admin\_username](#input\_local\_admin\_username) | n/a | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | n/a | yes |
| <a name="input_ou_path"></a> [ou\_path](#input\_ou\_path) | n/a | `string` | `null` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | n/a | `string` | n/a | yes |
| <a name="input_registration_token"></a> [registration\_token](#input\_registration\_token) | n/a | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | n/a | `string` | n/a | yes |
| <a name="input_session_host_sku"></a> [session\_host\_sku](#input\_session\_host\_sku) | n/a | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | n/a | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | `{}` | no |
| <a name="input_vm_count"></a> [vm\_count](#input\_vm\_count) | n/a | `number` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_session_host_ids"></a> [session\_host\_ids](#output\_session\_host\_ids) | IDs of created session hosts |
