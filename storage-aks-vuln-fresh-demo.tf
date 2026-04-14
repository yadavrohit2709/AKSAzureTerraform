# Storage Account for AKS Cluster - DEMO WITH VULNERABILITIES
# This file contains intentional security vulnerabilities for demonstration
# These vulnerabilities will be caught by Checkov security scanning
# Compatible with Azure Provider 3.15.00

resource "azurerm_storage_account" "aks_demo_vuln_storage" {
  name                     = "aksdemovuln001"
  resource_group_name      = "demo-resource-group"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  
  # VULNERABILITY: Weak TLS version - should use TLS1_2 (CKV_AZURE_44)
  min_tls_version          = "TLS1_0"
  
  # VULNERABILITY: Network rules allow public access (CKV_AZURE_59)
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
    Project     = "AKS Terraform Demo"
    Purpose     = "Checkov Security Scanning Demo"
  }
}

resource "azurerm_storage_container" "aks_demo_vuln_container" {
  name                  = "akslogsvuln"
  storage_account_name  = azurerm_storage_account.aks_demo_vuln_storage.name
  container_access_type = "blob"  # VULNERABILITY: Public blob access (CKV_AZURE_190)
}

output "aks_demo_vuln_storage_account_name" {
  value       = azurerm_storage_account.aks_demo_vuln_storage.name
  description = "Name of the vulnerable storage account for demo purposes"
}

output "aks_demo_vuln_storage_account_endpoint" {
  value       = azurerm_storage_account.aks_demo_vuln_storage.primary_blob_endpoint
  description = "Primary blob endpoint of the vulnerable storage account"
}
