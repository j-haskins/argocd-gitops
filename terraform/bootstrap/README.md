# Terraform State Backend Bootstrap

This folder contains the Terraform configuration to provision the Azure Storage resources required for storing remote Terraform state.

## Why Local State?
This configuration uses **local state** because it is bootstrapping the remote backend infrastructure itself. 

## Deployment Steps

1. Navigate to this directory:
   ```bash
   cd terraform/bootstrap
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Run the apply command to import or create the resources:
   ```bash
   terraform apply
   ```

## Importing Existing Resources
If the Resource Group and Storage Account were already created manually or via CLI, you can import them into the state file before managing them:

```bash
terraform import azurerm_resource_group.state_rg /subscriptions/<subscription-id>/resourceGroups/rg-argocd-gitops-tfstate

terraform import azurerm_storage_account.state_sa /subscriptions/<subscription-id>/resourceGroups/rg-argocd-gitops-tfstate/providers/Microsoft.Storage/storageAccounts/sargocdgitopstfstate

terraform import azurerm_storage_container.state_container https://sargocdgitopstfstate.blob.core.windows.net/tfstate
```
