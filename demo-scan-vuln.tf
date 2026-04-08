# =============================================================================
# DEMO: Infrastructure Security Scanning - Intentional Vulnerabilities
# This file is for demonstration purposes only
# DO NOT use in production environments
# =============================================================================

# -----------------------------------------------------------------------------
# Storage Account with Security Vulnerabilities
# -----------------------------------------------------------------------------
resource "azurerm_storage_account" "demo_vuln_storage" {
  name                     = "demovulnstorage${random_string.storage_name.result}"
  resource_group_name      = azurerm_resource_group.demo.name
  location                 = azurerm_resource_group.demo.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  # SECURITY VULNERABILITY: Public blob access enabled
  allow_blob_public_access = true
  
  # SECURITY VULNERABILITY: Weak TLS version (not enforced)
  min_tls_version          = "TLS1_0"
  
  # SECURITY VULNERABILITY: Large file shares enabled
  large_file_share_enabled = true
  
  tags = {
    environment = "demo"
    demo        = "true"
  }
}

# Resource group for demo resources
resource "azurerm_resource_group" "demo" {
  name     = "demo-security-rg"
  location = "eastus"
}

# Random string for unique storage name
resource "random_string" "storage_name" {
  length  = 8
  special = false
  upper   = false
}

# -----------------------------------------------------------------------------
# Virtual Machine with Security Vulnerabilities
# -----------------------------------------------------------------------------
resource "azurerm_virtual_machine" "demo_vuln_vm" {
  name                  = "demo-vuln-vm"
  location              = azurerm_resource_group.demo.location
  resource_group_name   = azurerm_resource_group.demo.name
  network_interface_ids = [azurerm_network_interface.demo_nic.id]
  vm_size               = "Standard_DS1_v2"

  storage_os_disk {
    name              = "demo-vuln-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"  # SECURITY VULNERABILITY: Unencrypted disk
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "demovuln"
    admin_username = "adminuser"
    # SECURITY VULNERABILITY: Hardcoded password
    admin_password = "P@ssw0rd123!Test"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

# Network interface for VM
resource "azurerm_network_interface" "demo_nic" {
  name                = "demo-vuln-nic"
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.demo_subnet.id
    private_ip_address_allocation = "dynamic"
    # SECURITY VULNERABILITY: No public IP but exposed to public subnet
  }
}

# Virtual Network
resource "azurerm_virtual_network" "demo_vnet" {
  name                = "demo-vuln-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name
}

# Subnet
resource "azurerm_subnet" "demo_subnet" {
  name                 = "demo-subnet"
  resource_group_name  = azurerm_resource_group.demo.name
  virtual_network_name = azurerm_virtual_network.demo_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# -----------------------------------------------------------------------------
# SQL Server with Security Vulnerabilities
# -----------------------------------------------------------------------------
resource "azurerm_mssql_server" "demo_vuln_sql" {
  name                         = "demo-vuln-sql-${random_string.sql_name.result}"
  resource_group_name          = azurerm_resource_group.demo.name
  location                     = azurerm_resource_group.demo.location
  version                      = "12.0"
  administrator_login          = "adminuser"
  # SECURITY VULNERABILITY: Hardcoded password
  administrator_login_password = "P@ssw0rd123!Test"
  
  # SECURITY VULNERABILITY: Public network access enabled
  public_network_access_enabled = true
  
  # SECURITY VULNERABILITY: No threat detection
  threat_detection_policy {
    enabled = false
  }
}

resource "random_string" "sql_name" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_mssql_database" "demo_db" {
  name      = "demo-vuln-db"
  server_id = azurerm_mssql_server.demo_vuln_sql.id
  sku_name  = "S0"
}

# -----------------------------------------------------------------------------
# Cosmos DB Account with Security Vulnerabilities
# -----------------------------------------------------------------------------
resource "azurerm_cosmosdb_account" "demo_vuln_cosmos" {
  name                = "demo-vuln-cosmos-${random_string.cosmos_name.result}"
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  capabilities {
    name = "EnableTable"
  }

  consistency_policy {
    level               = "Session"
    consistency_interval = 10
  }

  geo_location {
    failover_priority = 0
    location          = azurerm_resource_group.demo.location
  }

  # SECURITY VULNERABILITY: Public network access enabled
  public_network_access_enabled = true
  
  # SECURITY VULNERABILITY: Metadata write access enabled
  is_virtual_network_filter_enabled = false
}

resource "random_string" "cosmos_name" {
  length  = 8
  special = false
  upper   = false
}

# -----------------------------------------------------------------------------
# Key Vault with Security Vulnerabilities
# -----------------------------------------------------------------------------
resource "azurerm_key_vault" "demo_vuln_kv" {
  name                        = "demo-vuln-kv-${random_string.kv_name.result}"
  location                    = azurerm_resource_group.demo.location
  resource_group_name         = azurerm_resource_group.demo.name
  enabled_for_disk_encryption = true
  tenant_id                   = "00000000-0000-0000-0000-000000000000"
  
  sku_name = "standard"

  access_policy {
    tenant_id = "00000000-0000-0000-0000-000000000000"
    object_id = "00000000-0000-0000-0000-000000000000"
    
    certificate_permissions = [
      "Delete",
      "List",
    ]
    
    key_permissions = [
      "Delete",
      "List",
    ]
    
    secret_permissions = [
      "Delete",
      "List",
      "Set",
    ]
  }
  
  # SECURITY VULNERABILITY: Network ACLs not configured (allows all access)
  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
}

resource "random_string" "kv_name" {
  length  = 8
  special = false
  upper   = false
}

# =============================================================================
# SUMMARY OF SECURITY VULNERABILITIES
# =============================================================================
# 
# | Check ID      | Resource Type              | Issue Description                    |
# |---------------|----------------------------|--------------------------------------|
# | CKV_AZURE_35  | azurerm_storage_account    | Public blob access enabled           |
# | CKV_AZURE_44  | azurerm_storage_account    | Weak TLS version (1.0)               |
# | CKV_AZURE_149 | azurerm_storage_account    | Large file shares enabled            |
# | CKV_AZURE_3   | azurerm_virtual_machine    | Managed disk not encrypted (LRS)     |
# | CKV_AZURE_109 | azurerm_virtual_machine    | Hardcoded password in config         |
# | CKV_AZURE_117 | azurerm_mssql_server       | Public network access enabled         |
# | CKV_AZURE_117 | azurerm_cosmosdb_account   | Public network access enabled         |
# | CKV_AZURE_109 | azurerm_mssql_server       | Hardcoded password in config         |
# | CKV_AZURE_33  | azurerm_key_vault          | Network ACLs not properly configured |
#
# =============================================================================
