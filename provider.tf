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
  
  # Use client secret or service principal in CI/CD
  # For GitHub Actions, use ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_TENANT_ID, ARM_SUBSCRIPTION_ID
  # Or use managed identity (MSI) if available
  use_msi = true
  
  # Skip validation when no credentials available
  skip_credentials_validation = true
}

# Environment variables for Azure provider
# Set these in GitHub Actions secrets:
# - ARM_CLIENT_ID
# - ARM_CLIENT_SECRET  
# - ARM_TENANT_ID
# - ARM_SUBSCRIPTION_ID
