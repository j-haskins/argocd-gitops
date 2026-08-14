terraform {
  required_version = ">= 1.0.0"
  backend "azurerm" {
    resource_group_name  = "rg-argocd-gitops-tfstate"
    storage_account_name = "sargocdgitopstfstate"
    container_name       = "tfstate"
    key                  = "dev/terraform.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "aks_gitops" {
  source = "../../modules/aks-gitops"

  environment         = var.environment
  location            = var.location
  resource_group_name = var.resource_group_name
  cluster_name        = var.cluster_name
  node_count          = var.node_count
  vm_size             = var.vm_size
  acr_name            = var.acr_name
  vnet_cidr           = var.vnet_cidr
  subnet_cidr         = var.subnet_cidr
  max_pods            = var.max_pods
}

provider "kubernetes" {
  host                   = module.aks_gitops.aks_host
  client_certificate     = base64decode(module.aks_gitops.aks_client_certificate)
  client_key             = base64decode(module.aks_gitops.aks_client_key)
  cluster_ca_certificate = base64decode(module.aks_gitops.aks_cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = module.aks_gitops.aks_host
    client_certificate     = base64decode(module.aks_gitops.aks_client_certificate)
    client_key             = base64decode(module.aks_gitops.aks_client_key)
    cluster_ca_certificate = base64decode(module.aks_gitops.aks_cluster_ca_certificate)
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "5.46.7" # Stable Argo CD Helm Chart Version
  namespace        = "argocd"
  create_namespace = true

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  # Ensure helm deployment waits for cluster to be ready and identity to be mapped
  depends_on = [
    module.aks_gitops
  ]
}
