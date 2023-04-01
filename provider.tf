terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.15.00"
    }
  }  
  backend "azurerm" {
    resource_group_name = var.BKSTRGRG
    storage_account_name = var.BKSTRG
    container_name = var.BKCONTAINER
    key = var.BKSTREGKEY
  }
}
provider "azurerm" {
  features {}
}
