resource "azurerm_nat_gateway" "cv-nat" {
    for_each = var.nats
    name = each.value.name
    location = each.value.location
    resource_group_name = each.value.resource_group_name
    sku_name = each.value.sku_name 
}

resource "azurerm_nat_gateway_public_ip_association" "nat-pip" {
  for_each = var.nats
  nat_gateway_id = azurerm_nat_gateway.cv-nat[each.key].id
  public_ip_address_id = data.azurerm_public_ip.data_pip[each.key].id

}

resource "azurerm_subnet_nat_gateway_association" "frontend_nat_association" {
    for_each = var.nats
    nat_gateway_id = azurerm_nat_gateway.cv-nat[each.key].id
    subnet_id = data.azurerm_subnet.data_frontend_sub[each.key].id
}

resource "azurerm_subnet_nat_gateway_association" "backend_nat_association" {
    for_each = var.nats
    nat_gateway_id = azurerm_nat_gateway.cv-nat[each.key].id
    subnet_id = data.azurerm_subnet.data_backend_sub[each.key].id
}

data "azurerm_subnet" "data_frontend_sub" {
  for_each = var.nats
  name = each.value.data_frontend_sub_name
  resource_group_name = each.value.resource_group_name
  virtual_network_name = each.value.virtual_network_name
}

data "azurerm_subnet" "data_backend_sub" {
  for_each = var.nats
  name = each.value.data_backend_sub_name
  resource_group_name = each.value.resource_group_name
  virtual_network_name = each.value.virtual_network_name
}

data "azurerm_public_ip" "data_pip" {
  for_each = var.nats
  name = each.value.data_pip_name
  resource_group_name = each.value.resource_group_name
}

