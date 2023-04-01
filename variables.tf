variable "bkstrgrg" {
  type        = string
  description = "The name of the backend storage account resource group"
}

variable "bkstrg" {
  type        = string
  description = "The name of the backend storage account"
}

variable "bkcontainer" {
  type = string
  description = "The container name for the backend config"
}

variable "bkstrgkey" {
  type = string
  description = "The access key for the storage account"
}

variable "aks_vnet_name" {
    type = string
}

variable "keyvault_rg" {
  type    = string
}
variable "keyvault_name" {
  type    = string
}

variable "sshkvsecret" {
  type    = string
}

variable "clientidkvsecret" {
  type    = string
}

variable "vnetcidr" {
  type    = list
}

variable "subnetcidr" {
  type    = list
}

variable "spnkvsecret" {
  type    = string
}

variable "azure_region" {
  type    = string
}

#  Resource Group Name
variable "resource_group" {
  type    = string
}

# AKS Cluster name
variable "cluster_name" {
  type    = string
}

#AKS DNS name
variable "dns_name" {
  type    = string
}

variable "admin_username" {
  type    = string
}

# Specify a valid kubernetes version
variable "kubernetes_version" {
  type    = string
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
}
