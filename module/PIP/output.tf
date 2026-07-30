output "public_ips" {
  description = "Public IP Addresses"

  value = {
    for k, pip in azurerm_public_ip.cvpip :
    k => pip.ip_address
  }
}