resource "azurerm_resource_group" "cv-rg" {
    for_each = var.rgs
    name = each.value.name
    location = each.value.location 
}