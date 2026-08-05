resource "azurerm_mssql_server" "sql_server" {
  for_each = var.sql_servers

  name                         = each.value.server_name
  resource_group_name          = each.value.resource_group_name
  location                     = each.value.location
  version                      = each.value.version
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password
  minimum_tls_version          = "1.2"
  public_network_access_enabled = true
}

resource "azurerm_mssql_database" "database" {
  for_each = var.sql_servers

  name      = each.value.database_name
  server_id = azurerm_mssql_server.sql_server[each.key].id
  max_size_gb = each.value.max_size_gb
  zone_redundant = each.value.zone_redundant
}

resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  for_each = var.sql_servers
  name = each.value.sqlfwrule_name
  server_id = azurerm_mssql_server.sql_server[each.key].id
  start_ip_address = "0.0.0.0"
  end_ip_address = "0.0.0.0"
}