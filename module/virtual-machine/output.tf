#Module Output

output "vm_private_ips" {
  description = "Private IP addresses of all VMs"
  value = {
    for vm_name, nic in azurerm_network_interface.vm_nic :
    vm_name => nic.private_ip_address
  }

}