module "rg_module" {
  source = "../../module/resource-group"
  rgs    = var.rgs
}

module "vnet-module" {
  source     = "../../module/virtual-network"
  vnets      = var.vnets
  depends_on = [module.rg_module]
}

module "subnet_module" {
  source     = "../../module/subnet"
  snets      = var.snets
  depends_on = [module.rg_module, module.vnet-module]
}

module "nsg_module" {
  source     = "../../module/NSG"
  nsgs       = var.nsgs
  depends_on = [module.rg_module, module.vnet-module, module.subnet_module]
}

module "pip_module" {
  source     = "../../module/PIP"
  pips       = var.pips
  depends_on = [module.rg_module, module.subnet_module]
}

module "nat-module" {
  source     = "../../module/NAT"
  nats       = var.nats
  depends_on = [module.pip_module, module.subnet_module]
}

module "bastion_module" {
  source     = "../../module/Azure-Bastion"
  bastion    = var.bastion
  depends_on = [module.rg_module, module.pip_module, module.subnet_module]
}


module "vm_module" {
  source     = "../../module/virtual-machine"
  vms        = var.vms
  depends_on = [module.rg_module, module.vnet-module, module.subnet_module, module.nsg_module]
}

module "sql_module" {
  source      = "../../module/SQL-Database"
  sql_servers = var.sql_servers
  depends_on  = [module.rg_module]
}

module "apgw_module" {
  source     = "../../module/Application-Gateway"
  APGws      = var.APGws
  depends_on = [module.rg_module, var.vnets, module.pip_module, module.subnet_module, module.vm_module]
}


module "keyvault" {
  source = "../../module/KeyVault"
   key_vault = var.key_vault  
}