variable "environment" {
  description = "The deployment environment name"
  type        = string
  default     = "prod"
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "Central US"
}

variable "resource_group_name" {
  description = "The name of the resource group for prod environment"
  type        = string
  default     = "rg-argocd-gitops-prod"
}

variable "cluster_name" {
  description = "The name of the AKS cluster for prod environment"
  type        = string
  default     = "aks-gitops-prod"
}

variable "node_count" {
  description = "The number of nodes in the default system node pool"
  type        = number
  default     = 3
}

variable "vm_size" {
  description = "The VM size for the AKS default system node pool"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "acr_name" {
  description = "The name of the Azure Container Registry (must be globally unique and alphanumeric)"
  type        = string
  default     = "acrargocdgitopsprod"
}

variable "vnet_cidr" {
  description = "The CIDR block for the Virtual Network"
  type        = string
  default     = "10.20.0.0/16"
}

variable "subnet_cidr" {
  description = "The CIDR block for the AKS subnet"
  type        = string
  default     = "10.20.1.0/24"
}

variable "max_pods" {
  description = "The maximum number of pods that can run on a node in the default system node pool"
  type        = number
  default     = 50
}

