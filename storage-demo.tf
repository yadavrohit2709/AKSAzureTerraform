# Storage Account for AKS Cluster - DEMO WITH VULNERABILITIES
# This file contains intentional security vulnerabilities for demonstration

resource "azurerm_storage_account" "demo_storage" {
  name                     = "aksstorageaccountdemo"
  resource_group_name      = "demo-resource-group"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  
  # VULNERABILITY: Public access enabled - needs to be disabled for production
  allow_blob_public_access = true
  
  # VULNERABILITY: Weak TLS version - should use TLS1_2
  min_tls_version          = "TLS1_0"
  
  # VULNERABILITY: Network rules allow public access
  network_rules {
    default_action = "Allow"
  }
  
  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }

  tags = {
    Environment = "Demo"
    Project = "AKS Terraform Demo"
  }
}

resource "azurerm_storage_container" "demo_container" {
  name                  = "akslogs"
  storage_account_name = azurerm_storage_account.demo_storage.name
  container_access_type = "blob"  # VULNERABILITY: Public blob access
}

output "storage_account_name" {
  value = azurerm_storage_account.demo_storage.name
}

output "storage_account_endpoint" {
  value = azurerm_storage_account.demo_storage.primary_blob_endpoint
}