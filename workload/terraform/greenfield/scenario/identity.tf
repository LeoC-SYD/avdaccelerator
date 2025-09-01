resource "random_password" "dc_admin" {
  count   = var.join_method == "domain_join" && var.aadds_password == null ? 1 : 0
  length  = 16
  special = true
}

resource "azuread_user" "dc_admin" {
  count                 = var.join_method == "domain_join" && var.aadds_username == null ? 1 : 0
  user_principal_name   = local.join_upn
  display_name          = "AADDS Join Account"
  password              = local.domain_join_creds.password
  force_password_change = false
}
