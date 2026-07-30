resource "azurerm_bastion_host" "cv_bastion" {
    for_each = var.bastion
    name = each.value.name
    location = each.value.location
    resource_group_name = each.value.resource_group_name
    sku = each.value.sku
    ip_configuration {
        name = each.value.pip_name
        subnet_id =  data.azurerm_subnet.bastion-sub[each.key].id
        public_ip_address_id = data.azurerm_public_ip.bastion_pip[each.key].id
    }  
}


data "azurerm_subnet" "bastion-sub" {
  for_each = var.bastion
  name = each.value.data_sub_name
  resource_group_name = each.value.resource_group_name
  virtual_network_name = each.value.virtual_network_name
}

data "azurerm_public_ip" "bastion_pip" {
  for_each = var.bastion
  name = each.value.pip_name
  resource_group_name = each.value.resource_group_name
}

