output "resource_group_name" {
  description = "The name of the Resource Group created."
  value       = module.aks_gitops.resource_group_name
}

output "aks_cluster_name" {
  description = "The name of the AKS cluster."
  value       = module.aks_gitops.aks_cluster_name
}

output "acr_name" {
  description = "The name of the Azure Container Registry."
  value       = module.aks_gitops.acr_name
}

output "acr_login_server" {
  description = "The login server URL for the ACR."
  value       = module.aks_gitops.acr_login_server
}

output "connect_command" {
  description = "Command to configure kubectl to connect to the AKS cluster."
  value       = "az aks get-credentials --resource-group ${module.aks_gitops.resource_group_name} --name ${module.aks_gitops.aks_cluster_name}"
}

output "argocd_password_bash" {
  description = "Command (Bash) to retrieve the admin password for Argo CD."
  value       = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 --decode"
}

output "argocd_password_powershell" {
  description = "Command (PowerShell) to retrieve the admin password for Argo CD."
  value       = "[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String((kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\")))"
}
