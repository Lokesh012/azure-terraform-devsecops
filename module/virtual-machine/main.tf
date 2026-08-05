data "azurerm_subnet" "vm_subnet" {
  for_each = var.vms
  name                 = each.value.subnet_name
  resource_group_name  = each.value.resource_group_name
  virtual_network_name = each.value.virtual_network_name
}

# NIC


resource "azurerm_network_interface" "vm_nic" {
  for_each = var.vms
  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  ip_configuration {

    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.vm_subnet[each.key].id
    private_ip_address_allocation = each.value.private_ip_address_allocation
    private_ip_address = each.value.private_ip_address
  }
}

# Linux VM


resource "azurerm_linux_virtual_machine" "vm" {

  for_each = var.vms

  name                = each.value.name
  computer_name       = each.value.computer_name

  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  size = each.value.vm_size

  admin_username = each.value.admin_username
  disable_password_authentication = each.value.disable_password_authentication
  
  admin_ssh_key {
    username = each.value.admin_username
    public_key = each.value.public_key
  }
  custom_data = base64encode(file(each.value.custom_data))
  network_interface_ids = [azurerm_network_interface.vm_nic[each.key].id]


  os_disk {
    name                 = each.value.os_disk_name
    caching              = each.value.caching
    storage_account_type = each.value.storage_account_type

  }

  source_image_reference {
    publisher = each.value.publisher
    offer     = each.value.offer
    sku       = each.value.sku
    version   = each.value.version
  }
}