# Storage Account for AKS Cluster - FIXED VERSION
# Security vulnerabilities have been addressed
# Fixed version for Checkov security demo

resource "azurerm_storage_account" "aks_aksdemo_storage" {
  name                     = "aksaksdemostorage001"
  resource_group_name      = "demo-resource-group"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  
  # FIXED: Using TLS1_2 instead of TLS1_0
  min_tls_version          = "TLS1_2"
  
  # FIXED: HTTPS traffic only enabled
  enable_https_traffic_only = true
  
  # FIXED: Network rules deny public access
  network_rules {
    default_action = "Deny"
    bypass = ["AzureServices"]
  }
  
  # Queue properties with logging enabled
  queue_properties {
    logging {
      delete = true
      read = true
      write = true
      version = "1.0"
      retention_policy_days = 7
    }
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
  container_access_type = "private"  # FIXED: Private access instead of blob
}

output "aks_storage_account_name" {
  value = azurerm_storage_account.aks_aksdemo_storage.name
}

output "aks_storage_account_endpoint" {
  value = azurerm_storage_account.aks_aksdemo_storage.primary_blob_endpoint
}