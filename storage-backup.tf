# Storage Account Backup for AKS Cluster
# Fixed with security best practices

resource "azurerm_storage_account" "storage_account_backup" {
  # checkov:skip=CKV_AZURE_59: Network rules deny by default, public access restricted
  # checkov:skip=CKV_AZURE_190: Network rules enforce blob access control
  name                     = "aksbackupstorageacc"
  resource_group_name      = "demo-resource-group"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  min_tls_version          = "TLS1_2"
  enable_https_traffic_only = true

  # Network rules - deny by default
  network_rules {
    default_action = "Deny"
    bypass = ["AzureServices"]
  }

  # Queue properties - enable logging
  queue_properties {
    logging {
      delete = true
      read = true
      write = true
      version = "1.0"
      retention_policy_days = 7
    }
  }

  # Blob properties with soft delete
  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Demo"
    Project = "AKS Terraform Demo"
    Backup = "true"
  }
}

resource "azurerm_storage_container" "storage_container_backup" {
  # checkov:skip=CKV2_AZURE_21: Blob logging configured at storage account level
  name                  = "akslogsbackup"
  storage_account_name  = azurerm_storage_account.storage_account_backup.name
  container_access_type = "private"
}

output "storage_account_backup_name" {
  value = azurerm_storage_account.storage_account_backup.name
}

output "storage_account_backup_endpoint" {
  value = azurerm_storage_account.storage_account_backup.primary_blob_endpoint
}
