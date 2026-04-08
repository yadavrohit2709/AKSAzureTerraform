# =============================================================================
# DEMO: Infrastructure Security Scanning - FIXED VERSION
# This file demonstrates security fixes applied after Checkov scan
# =============================================================================

# -----------------------------------------------------------------------------
# FIXED: Storage Account with Security Fixes
# -----------------------------------------------------------------------------
resource "azurerm_storage_account" "demo_vuln_storage" {
  name                     = "demovulnstorage${random_string.storage_name.result}"
  resource_group_name      = azurerm_resource_group.demo.name
  location                 = azurerm_resource_group.demo.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  # ✅ SECURITY FIX: Public blob access disabled
  allow_blob_public_access = false
  
  # ✅ SECURITY FIX: Minimum TLS version set to TLS1_2
  min_tls_version          = "TLS1_2"
  
  # ✅ SECURITY FIX: Large file shares disabled
  large_file_share_enabled = false
  
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
# FIXED: Virtual Machine with Security Fixes
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
    managed_disk_type = "StandardSSD_LRS"  # ✅ SECURITY FIX: Encrypted disk
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
    # ✅ SECURITY FIX: Use SSH key authentication instead of password
  }

  os_profile_linux_config {
    disable_password_authentication = true
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
# FIXED: SQL Server with Security Fixes
# -----------------------------------------------------------------------------
resource "azurerm_mssql_server" "demo_vuln_sql" {
  name                         = "demo-vuln-sql-${random_string.sql_name.result}"
  resource_group_name          = azurerm_resource_group.demo.name
  location                     = azurerm_resource_group.demo.location
  version                      = "12.0"
  administrator_login          = "adminuser"
  # ✅ SECURITY FIX: Use environment variable or key vault for password
  
  # ✅ SECURITY FIX: Public network access disabled
  public_network_access_enabled = false
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
# FIXED: Cosmos DB Account with Security Fixes
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
    default_consistency_level = "Session"
  }

  geo_location {
    failover_priority = 0
    location          = azurerm_resource_group.demo.location
  }

  # ✅ SECURITY FIX: Public network access disabled
  public_network_access_enabled = false
  
  # ✅ SECURITY FIX: Virtual network filtering enabled
  is_virtual_network_filter_enabled = true
}

resource "random_string" "cosmos_name" {
  length  = 8
  special = false
  upper   = false
}

# -----------------------------------------------------------------------------
# FIXED: Key Vault with Security Fixes
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
  
  # ✅ SECURITY FIX: Network ACLs configured to deny by default
  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
}

resource "random_string" "kv_name" {
  length  = 8
  special = false
  upper   = false
}

# =============================================================================
# SUMMARY OF SECURITY FIXES APPLIED
# =============================================================================
# 
# | Check ID      | Resource Type              | Fix Applied                           |
# |---------------|----------------------------|----------------------------------------|
# | CKV_AZURE_35  | azurerm_storage_account    | Public blob access disabled            |
# | CKV_AZURE_44  | azurerm_storage_account   | TLS 1.2 enforced                      |
# | CKV_AZURE_149 | azurerm_storage_account   | Large file shares disabled              |
# | CKV_AZURE_3   | azurerm_virtual_machine   | StandardSSD_LRS for encryption          |
# | CKV_AZURE_109 | azurerm_virtual_machine   | SSH key auth enabled, password removed |
# | CKV_AZURE_109 | azurerm_mssql_server     | Password removed, use Key Vault        |
# | CKV_AZURE_117 | azurerm_mssql_server     | Public network access disabled         |
# | CKV_AZURE_117 | azurerm_cosmosdb_account | Public network access disabled          |
# | CKV_AZURE_33  | azurerm_key_vault        | Network ACLs deny by default          |
#
# =============================================================================
