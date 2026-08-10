variable "environment" {
  description = "The deployment environment name"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "The name of the resource group for dev environment"
  type        = string
  default     = "rg-argocd-gitops-dev"
}

variable "cluster_name" {
  description = "The name of the AKS cluster for dev environment"
  type        = string
  default     = "aks-gitops-dev"
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
  default     = "acrargocdgitopsdev"
}

variable "vnet_cidr" {
  description = "The CIDR block for the Virtual Network"
  type        = string
  default     = "10.10.0.0/16"
}

variable "subnet_cidr" {
  description = "The CIDR block for the AKS subnet"
  type        = string
  default     = "10.10.1.0/24"
}
