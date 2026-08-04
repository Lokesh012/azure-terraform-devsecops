####################################################
# Existing Resource Group
####################################################

data "azurerm_resource_group" "rg" {
  name = "backend-rg1"
}

####################################################
# Existing Storage Account
####################################################

# data "azurerm_storage_account" "tfstate" {

#   name                = "backendstorage03cont"
#   resource_group_name = data.azurerm_resource_group.rg.name

# }

####################################################
# Existing Key Vault
####################################################

data "azurerm_key_vault" "kv" {
  name                = "cv-landing-kv-79059"
  resource_group_name = data.azurerm_resource_group.rg.name
}

####################################################
# SQL Admin Username
####################################################

data "azurerm_key_vault_secret" "sql_username" {

  name         = "sql-admin-username"
  key_vault_id = data.azurerm_key_vault.kv.id

}

####################################################
# SQL Admin Password
####################################################

data "azurerm_key_vault_secret" "sql_password" {

  name         = "sql-admin-password"
  key_vault_id = data.azurerm_key_vault.kv.id

}