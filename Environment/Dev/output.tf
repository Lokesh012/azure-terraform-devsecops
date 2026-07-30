
#root Output


output "vm_private_ips" {
  value = module.vm_module.vm_private_ips
}

output "public_ips" {
  value = module.pip_module.public_ips
}
