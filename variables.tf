variable "BKSTRGRG" {
  type        = string
  description = "The name of the backend storage account resource group"
  default     = ""
}

variable "BKSTRG" {
  type        = string
  description = "The name of the backend storage account"
  default     = ""
}

variable "BKCONTAINER" {
  type        = string
  description = "The container name for the backend config"
  default     = ""
}

variable "BKSTREGKEY" {
  type        = string
  description = "The access key for the storage account"
  default     = ""
}

variable "aks_vnet_name" {
    type    = string
    default = "aks-vnet"
}

variable "keyvault_rg" {
  type    = string
  default = "keyvault-rg"
}
variable "keyvault_name" {
  type    = string
  default = "keyvault"
}

variable "sshkvsecret" {
  type    = string
  default = "ssh-public-key"
}

variable "clientidkvsecret" {
  type    = string
  default = "spn-client-id"
}

variable "vnetcidr" {
  type    = list
  default = ["10.0.0.0/16"]
}

variable "subnetcidr" {
  type    = list
  default = ["10.0.0.0/24"]
}

variable "spnkvsecret" {
  type    = string
  default = "spn-client-secret"
}

variable "azure_region" {
  type    = string
  default = "eastus"
}

#  Resource Group Name
variable "resource_group" {
  type    = string
  default = "aks-rg"
}

# AKS Cluster name
variable "cluster_name" {
  type    = string
  default = "aks-cluster"
}

#AKS DNS name
variable "dns_name" {
  type    = string
  default = "aksdemo"
}

variable "admin_username" {
  type    = string
  default = "aksuser"
}

# Specify a valid kubernetes version
variable "kubernetes_version" {
  type    = string
  default = "1.27"
}

#AKS Agent pools
variable "agent_pools" {
  type = object({
      name            = string
      count           = number
      vm_size         = string
      os_disk_size_gb = string
    }
  )
  default = {
    name            = "pool1"
    count           = 2
    vm_size         = "Standard_B2s"
    os_disk_size_gb = "30"
  }
}
