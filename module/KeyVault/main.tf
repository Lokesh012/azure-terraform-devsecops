data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {

  for_each = var.key_vault

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  tenant_id = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  rbac_authorization_enabled = true

  soft_delete_retention_days = 90

  purge_protection_enabled = true

  public_network_access_enabled = true

  tags = {
    Environment = "Dev"
    Project     = "CineVerse"
  }
}

resource "azurerm_role_assignment" "kv_admin" {

  for_each = azurerm_key_vault.kv

  scope = each.value.id

  role_definition_name = "Key Vault Administrator"

  principal_id = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_secret" "sql_username" {

  for_each = var.key_vault

  name         = "sql-admin-username"
  value        = each.value.sql_admin_username
  key_vault_id = azurerm_key_vault.kv[each.key].id

}

resource "azurerm_key_vault_secret" "sql_password" {

  for_each = var.key_vault

  name         = "sql-admin-password"
  value        = each.value.sql_admin_password
  key_vault_id = azurerm_key_vault.kv[each.key].id

}