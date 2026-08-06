terraform {
  required_version = ">= 1.10.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.81.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "backend-rg1"
    storage_account_name = "cvbackendst79059"
    container_name       = "backendcont03"
    key                  = "dev.terraform.tfstate"
  }

}

provider "azurerm" {
  features {}
}