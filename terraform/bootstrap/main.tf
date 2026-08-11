terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "state_rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = "global"
    ManagedBy   = "Terraform"
    Purpose     = "TerraformStateBackend"
  }
}

resource "azurerm_storage_account" "state_sa" {
  name                      = var.storage_account_name
  resource_group_name       = azurerm_resource_group.state_rg.name
  location                  = azurerm_resource_group.state_rg.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  min_tls_version           = "TLS1_2"
  allow_nested_items_to_be_public = false

  # Enable versioning for state files (strongly recommended to recover from corruption/accidental delete)
  blob_properties {
    versioning_enabled = true
  }

  tags = {
    Environment = "global"
    ManagedBy   = "Terraform"
    Purpose     = "TerraformStateBackend"
  }
}

resource "azurerm_storage_container" "state_container" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.state_sa.name
  container_access_type = "private"
}
