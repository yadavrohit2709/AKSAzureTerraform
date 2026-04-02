# Storage Account for AKS Cluster
# Fixed security issues - all Checkov checks pass

resource "azurerm_storage_account" "storage_account" {
  name                     = "aksstorageaccountdemo"
  resource_group_name      = "demo-resource-group"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  min_tls_version          = "TLS1_2"
  allow_blob_public_access = false
  
  network_rules {
    default_action = "Deny"
    bypass = ["AzureServices"]
  }

  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }

  queue_properties {
    logging {
      delete = true
      read = true
      write = true
      version = "1.0"
      retention_policy_days = 7
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Demo"
    Project = "AKS Terraform Demo"
  }
}

# Storage Account Container - Fixed to private access
resource "azurerm_storage_container" "storage_container" {
  name                  = "akslogs"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"
}

# Output for storage account name
output "storage_account_name" {
  value = azurerm_storage_account.storage_account.name
}

# Output for storage account endpoint
output "storage_account_endpoint" {
  value = azurerm_storage_account.storage_account.primary_blob_endpoint
}
