resource "azurerm_network_security_group" "cv_nsg" {
  for_each = var.nsgs
  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  dynamic "security_rule" {

    for_each = each.value.security_rules

    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}


data "azurerm_subnet" "subnet" {

  for_each = var.nsgs

  name                 = each.value.subnet_name
  virtual_network_name = each.value.virtual_network_name
  resource_group_name  = each.value.resource_group_name
}


resource "azurerm_subnet_network_security_group_association" "association" {

  for_each = var.nsgs

  subnet_id                 = data.azurerm_subnet.subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.cv_nsg[each.key].id
}





























# resource "azurerm_network_security_group" "cv-nsg" {
#     for_each = var.nsgs
#     name = each.value.name
#     location = each.value.location
#     resource_group_name = each.value.resource_group_name

#       security_rule {
#     name                       = "ssh"
#     priority                   = 100
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "22"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }
#       security_rule {
#     name                       = "http"
#     priority                   = 101
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "80"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }

#         security_rule {
#     name                       = "sql"
#     priority                   = 102
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "1433"
#     destination_port_range     = "*"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }

#           security_rule {
#     name                       = "sql"
#     priority                   = 103
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "5000"
#     destination_port_range     = "*"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }

# }

# resource "azurerm_subnet_network_security_group_association" "frontend_nsg_association" {
#     for_each = var.nsgs
#     network_security_group_id = azurerm_network_security_group.cv-nsg[each.key].id
#     subnet_id = data.azurerm_subnet.data_frontend_sub[each.key].id
# }

# resource "azurerm_subnet_network_security_group_association" "backend_nsg_association" {
#     for_each = var.nsgs
#     network_security_group_id = azurerm_network_security_group.cv-nsg[each.key].id
#     subnet_id = data.azurerm_subnet.data_backend_sub[each.key].id
# }

# data "azurerm_subnet" "data_frontend_sub" {
#   for_each = var.nsgs
#   name = each.value.data_frontend_sub_name
#   resource_group_name = each.value.resource_group_name
#   virtual_network_name = each.value.virtual_network_name
# }

# data "azurerm_subnet" "data_backend_sub" {
#   for_each = var.nsgs
#   name = each.value.data_backend_sub_name
#   resource_group_name = each.value.resource_group_name
#   virtual_network_name = each.value.virtual_network_name
# }