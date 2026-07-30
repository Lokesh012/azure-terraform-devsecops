output "keyvault_id" {

  value = {
    for k, v in azurerm_key_vault.kv :
    k => v.id
  }

}

output "keyvault_uri" {

  value = {
    for k, v in azurerm_key_vault.kv :
    k => v.vault_uri
  }

}