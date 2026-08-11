output "resource_group_name" {
  description = "The name of the Resource Group created for state storage"
  value       = azurerm_resource_group.state_rg.name
}

output "storage_account_name" {
  description = "The name of the Storage Account created for state storage"
  value       = azurerm_storage_account.state_sa.name
}

output "container_name" {
  description = "The name of the Blob Container created for state storage"
  value       = azurerm_storage_container.state_container.name
}
