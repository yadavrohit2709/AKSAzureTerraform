# Storage Account for AKS Cluster - DEMO WITH VULNERABILITIES
# This file contains intentional security vulnerabilities for demonstration
# Compatible with azurerm provider version 3.15.00

resource "azurerm_storage_account" "aks_aksdemo_storage" {
  name                     = "aksaksdemostorage001"
  resource_group_name      = "demo-resource-group"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  
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

resource "azurerm_storage_container" "aks_aksdemo_container" {
  name                  = "akslogs"
  storage_account_name = azurerm_storage_account.aks_aksdemo_storage.name
  container_access_type = "blob"  # VULNERABILITY: Public blob access
}

output "aks_storage_account_name" {
  value = azurerm_storage_account.aks_aksdemo_storage.name
}

output "aks_storage_account_endpoint" {
  value = azurerm_storage_account.aks_aksdemo_storage.primary_blob_endpoint
}