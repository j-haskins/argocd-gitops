variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "Central US"
}

variable "resource_group_name" {
  description = "The name of the resource group for Terraform state"
  type        = string
  default     = "rg-argocd-gitops-tfstate"
}

variable "storage_account_name" {
  description = "The name of the storage account for Terraform state (globally unique)"
  type        = string
  default     = "sargocdgitopstfstate"
}

variable "container_name" {
  description = "The name of the blob container for Terraform state"
  type        = string
  default     = "tfstate"
}
