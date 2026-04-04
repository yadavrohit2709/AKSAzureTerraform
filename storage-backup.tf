# Storage Account for AKS Cluster
# Backup configuration - Updated with security fixes

resource "azurerm_storage_account" "storage_account" {
  name                     = "aksstorageaccountdemo"
  resource_group_name      = "demo-resource-group"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  
  # SECURITY FIX: Public access disabled
  allow_blob_public_access = false
  
  # SECURITY FIX: TLS 1.2 minimum
  min_tls_version          = "TLS1_2"
  
  # SECURITY FIX: Network rules deny by default
  network_rules {
    default_action = "Deny"
    bypass = ["AzureServices"]
  }
  
  # SECURITY FIX: Enable HTTPS only
  enable_https_traffic_only = true
  
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

resource "azurerm_storage_container" "storage_container" {
  name                  = "akslogs"
  storage_account_name = azurerm_storage_account.storage_account.name
  # SECURITY FIX: Private access instead of blob
  container_access_type = "private"
}

output "storage_account_name" {
  value = azurerm_storage_account.storage_account.name
}

output "storage_account_endpoint" {
  value = azurerm_storage_account.storage_account.primary_blob_endpoint
}
