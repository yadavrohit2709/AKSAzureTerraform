# Storage Account for AKS Cluster
# This file contains intentional security issues for Checkov demo purposes

resource "azurerm_storage_account" "storage_account" {
  name                     = "aksstorageaccountdemo"
  resource_group_name      = "demo-resource-group"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  enable_https_traffic_only = false
  allow_blob_public_access = true
  
  network_rules {
    default_action = "Allow"
    bypass = ["AzureServices"]
  }

  tags = {
    Environment = "Demo"
    Project = "AKS Terraform Demo"
  }
}

# Storage Account Container
resource "azurerm_storage_container" "storage_container" {
  name                  = "akslogs"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "blob"
}

# Output for storage account name
output "storage_account_name" {
  value = azurerm_storage_account.storage_account.name
}
