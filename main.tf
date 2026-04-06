data "azurerm_key_vault" "azure_vault" {
  name                = var.keyvault_name
  resource_group_name = var.keyvault_rg
}

data "azurerm_key_vault_secret" "ssh_public_key" {
  name         = var.sshkvsecret
  key_vault_id = data.azurerm_key_vault.azure_vault.id
}

data "azurerm_key_vault_secret" "spn_id" {
  name         = var.clientidkvsecret
  key_vault_id = data.azurerm_key_vault.azure_vault.id
}
data "azurerm_key_vault_secret" "spn_secret" {
  name         = var.spnkvsecret
  key_vault_id = data.azurerm_key_vault.azure_vault.id
}

data "azurerm_resource_group" "aks_rg" {
  name     = var.resource_group
}

# Log Analytics Workspace for AKS monitoring
resource "azurerm_log_analytics_workspace" "aks_logs" {
  name                = "${var.cluster_name}-logs"
  location            = data.azurerm_resource_group.aks_rg.location
  resource_group_name = data.azurerm_resource_group.aks_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_virtual_network" "aks_vnet" {
  name                = var.aks_vnet_name
  resource_group_name = data.azurerm_resource_group.aks_rg.name
  location            = data.azurerm_resource_group.aks_rg.location
  address_space       = var.vnetcidr
}

# Network Security Group for subnet
resource "azurerm_network_security_group" "aks_nsg" {
  name                = "aks-nsg"
  location            = data.azurerm_resource_group.aks_rg.location
  resource_group_name = data.azurerm_resource_group.aks_rg.name

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["443", "80"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks_subnet"
  resource_group_name = data.azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = var.subnetcidr

  delegation {
    name = "aksdelegation"
    service_delegation {
      name    = "Microsoft.ContainerService/managedClusters"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# Associate NSG with subnet
resource "azurerm_subnet_network_security_group_association" "aks_nsg_assoc" {
  subnet_id                 = azurerm_subnet.aks_subnet.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.cluster_name
  location            = data.azurerm_resource_group.aks_rg.location
  resource_group_name = data.azurerm_resource_group.aks_rg.name
  dns_prefix          = var.dns_name

  # Enable private cluster
  private_cluster_enabled = true
  private_dns_zone_id    = "System"

  # RBAC enabled
  role_based_access_control_enabled = true

  default_node_pool {
    name            = var.agent_pools.name
    node_count      = var.agent_pools.count
    vm_size         = var.agent_pools.vm_size
    os_disk_size_gb = var.agent_pools.os_disk_size_gb
    type            = "VirtualMachineScaleSets"
    os_disk_type    = "Managed"
    max_pods        = 50
  }

  linux_profile {
    admin_username = var.admin_username
    ssh_key {
      key_data = data.azurerm_key_vault_secret.ssh_public_key.value
    }
  }

  service_principal {
    client_id     = data.azurerm_key_vault_secret.spn_id.value
    client_secret = data.azurerm_key_vault_secret.spn_secret.value
  }

  # Enable Azure Monitor logging
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.aks_logs.id
  }

  # Disable HTTP application routing
  http_application_routing_enabled = false

  # Network policy
  network_profile {
    network_plugin     = "azure"
    network_policy    = "calico"
    load_balancer_sku = "standard"
  }

  # SKU - Paid tier for SLA
  sku_tier = "Paid"

  # Azure Policy add-on
  azure_policy_enabled = true

  # Secret store CSI driver
  key_vault_secrets_provider {
    secret_rotation_enabled = "true"
  }

  # API Server authorized IP ranges (restrict to VNet)
  api_server_authorized_ip_ranges = [
    azurerm_virtual_network.aks_vnet.address_space[0]
  ]

  tags = {
    Environment = "Demo"
  }
}
