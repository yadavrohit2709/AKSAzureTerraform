terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.15.00"
    }
  }  
  # For CI/CD without Azure credentials, use local backend
  # Uncomment the azurerm backend below when you have Azure credentials
  /*
  backend "azurerm" {
    resource_group_name = var.BKSTRGRG
    storage_account_name = var.BKSTRG
    container_name = var.BKCONTAINER
    key = var.BKSTREGKEY
  }
  */
}
provider "azurerm" {
  features {}
  # Skip provider initialization in CI/CD without credentials
  skip_provider_registration = true
}
