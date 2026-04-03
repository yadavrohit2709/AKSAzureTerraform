terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.15.00"
    }
  }  
  # Commented out for CI/CD without Azure credentials
  # Uncomment when you have Azure backend configured
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
  skip_provider_registration = true
  use_msi = true
  subscription_id = "dummy-subscription"
}

# Dummy provider for validation only (no real authentication)
provider "azurerm" "dummy" {
  features {}
  skip_provider_registration = true
  alias = "for_validation"
}
