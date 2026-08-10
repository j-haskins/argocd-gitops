variable "environment" {
  description = "The deployment environment (e.g., dev, prod)"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "cluster_name" {
  description = "The name of the AKS cluster"
  type        = string
}

variable "node_count" {
  description = "The number of nodes in the default system node pool"
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "The VM size for the AKS default system node pool"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "acr_name" {
  description = "The name of the Azure Container Registry (must be globally unique and alphanumeric)"
  type        = string
}

variable "vnet_cidr" {
  description = "The CIDR block for the Virtual Network"
  type        = string
  default     = "10.0.0.0/8"
}

variable "subnet_cidr" {
  description = "The CIDR block for the AKS subnet"
  type        = string
  default     = "10.240.0.0/16"
}
