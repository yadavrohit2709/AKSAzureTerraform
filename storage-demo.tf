# Storage Account for AKS Cluster - FIXED
# Security vulnerabilities have been addressed

resource "azurerm_storage_account" "demo_storage" {
  name                     = "aksstorageaccountdemo"
  resource_group_name      = "demo-resource-group"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  
  # FIXED: Public access disabled
  allow_blob_public_access = false
  
  # FIXED: TLS 1.2 enforced
  min_tls_version          = "TLS1_2"
  
  # FIXED: Enable HTTPS only
  enable_https_traffic_only = true
  
  # FIXED: Network rules deny by default
  network_rules {
    default_action = "Deny"
    bypass = ["AzureServices"]
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
  container_access_type = "private"  # FIXED: Private access
}

output "storage_account_name" {
  value = azurerm_storage_account.demo_storage.name
}

output "storage_account_endpoint" {
  value = azurerm_storage_account.demo_storage.primary_blob_endpoint
}