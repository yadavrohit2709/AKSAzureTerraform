# Demo Terraform file with intentional security vulnerabilities
# This file is for demonstrating Checkov security scanning
# DO NOT use this configuration in production!

# Resource Group for Demo Resources
resource "azurerm_resource_group" "demo_rg" {
  name     = "demo-security-scan-rg"
  location = "eastus"
}

# Storage Account with PUBLIC ACCESS ENABLED - SECURITY VULNERABILITY
# This triggers CKV_AZURE_35: "Ensure 'Allow blob public access' is disabled"
resource "azurerm_storage_account" "demo_sc" {
  name                     = "demostorageacct2024"  # Different name from storage-demo.tf
  resource_group_name       = azurerm_resource_group.demo_rg.name
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type  = "LRS"
  
  # SECURITY ISSUE: Public blob access enabled
  allow_blob_public_access = true
  
  # WEAK TLS SETTING - Using TLS 1.0 (triggers CKV_AZURE_23)
  min_tls_version          = "TLS1_0"
  
  # Missing network rules configuration - allows all traffic by default
  # This triggers CKV_AZURE_33
  
  tags = {
    Environment = "Demo"
    Purpose     = "Checkov Security Scan Demo"
  }
}

# Storage Container with PUBLIC ACCESS - SECURITY VULNERABILITY
# Container configured for anonymous access
resource "azurerm_storage_container" "demo_container" {
  name                  = "demo-public-container"
  storage_account_name   = azurerm_storage_account.demo_sc.name
  container_access_type  = "blob"  # Public read access
  
  # SECURITY ISSUE: Blob-level public access enabled
}

# Storage Share for file shares (also publicly accessible)
resource "azurerm_storage_share" "demo_share" {
  name                 = "demo-fileshare"
  storage_account_name = azurerm_storage_account.demo_sc.name
  quota                = 50
  
  # Note: File shares don't have explicit public access setting
  # but combined with the storage account settings, this is insecure
}

# Virtual Machine with WEAK SECURITY - SECURITY VULNERABILITY
# This triggers CKV_AZURE_3: "Ensure managed disks are encrypted"
resource "azurerm_virtual_machine" "demo_vm" {
  name                  = "demo-vulnerable-vm"
  location              = azurerm_resource_group.demo_rg.location
  resource_group_name   = azurerm_resource_group.demo_rg.name
  network_interface_ids  = []  # Placeholder - would need NIC
  vm_size               = "Standard_DS1_v2"
  
  storage_os_disk {
    name              = "demo-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"  # SECURITY ISSUE: Not encrypted
  }
  
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  
  os_profile {
    computer_name  = "demovm"
    admin_username = "demouser"
    admin_password = "DemoPass123!"  # SECURITY ISSUE: Hardcoded password
  }
  
  os_profile_linux_config {
    disable_password_authentication = false  # SECURITY ISSUE: Password auth enabled
  }
  
  tags = {
    Environment = "Demo"
    Purpose     = "Checkov Security Scan Demo"
  }
}

# Key Vault with OPEN ACCESS POLICY - SECURITY VULNERABILITY
# This triggers CKV_AZURE_109: "Ensure no sensitive credentials are configured in tf files"
resource "azurerm_key_vault" "demo_kv" {
  name                        = "demo-keyvault-2024"
  location                    = azurerm_resource_group.demo_rg.location
  resource_group_name         = azurerm_resource_group.demo_rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = "00000000-0000-0000-0000-000000000000"
  
  sku_name = "standard"
  
  # SECURITY ISSUE: Access policies not properly configured
  access_policy {
    tenant_id = "00000000-0000-0000-0000-000000000000"
    object_id = "00000000-0000-0000-0000-000000000000"
    
    key_permissions = [
      "Get", "List", "Update", "Create", "Import",
      "Delete", "Recover", "Backup", "Restore"
    ]
    
    secret_permissions = [
      "Get", "List", "Set", "Delete", "Recover",
      "Backup", "Restore"
    ]
  }
  
  # SECURITY ISSUE: Network ACLs not configured - accessible from all networks
}

# SQL Server with PUBLIC ACCESS - SECURITY VULNERABILITY
# This triggers CKV_AZURE_117, CKV_AZURE_118
resource "azurerm_mssql_server" "demo_sql" {
  name                         = "demo-sql-server-2024"
  resource_group_name          = azurerm_resource_group.demo_rg.name
  location                     = azurerm_resource_group.demo_rg.location
  administrator_login          = "demosa"
  administrator_login_password = "DemoPass123!"  # SECURITY ISSUE: Hardcoded password
  
  # SECURITY ISSUE: Public network access enabled
  public_network_access_enabled = true
  
  # Minimum TLS version not set - defaults to TLS 1.0
}

# SQL Database with NO FIREWALL RULES
resource "azurerm_mssql_database" "demo_db" {
  name      = "demo-sql-database"
  server_id = azurerm_mssql_server.demo_sql.id
  
  sku_name = "S0"
}

# Cosmos DB Account with PUBLIC ACCESS - SECURITY VULNERABILITY
resource "azurerm_cosmosdb_account" "demo_cosmos" {
  name                = "demo-cosmosdb-2024"
  location            = azurerm_resource_group.demo_rg.location
  resource_group_name = azurerm_resource_group.demo_rg.name
  offer_type          = "Standard"
  
  geo_location {
    location          = "eastus"
    failover_priority = 0
  }
  
  # SECURITY ISSUE: Public network access enabled
  public_network_access_enabled = true
  
  # SECURITY ISSUE: Firewall not configured - access from all IPs
}

# Output to show resources created
output "storage_account_name" {
  value = azurerm_storage_account.demo_sc.name
}

output "key_vault_name" {
  value = azurerm_key_vault.demo_kv.name
}

output "sql_server_name" {
  value = azurerm_mssql_server.demo_sql.name
}
