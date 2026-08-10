# ArgoCD GitOps Repository

This repository hosts the GitOps configuration for managing Kubernetes applications using ArgoCD. It is structured to support multi-environment deployments using Kustomize overlays.

## Repository Structure

```text
argocd-gitops/
├── bootstrap/             # Bootstrapping files (App-of-Apps pattern)
│   ├── dev-root.yaml      # Root Application for Dev environment
│   └── prod-root.yaml     # Root Application for Prod environment
├── apps/                  # ArgoCD Application definitions
│   ├── dev/               # Dev applications (points to environments/dev)
│   │   └── guestbook.yaml
│   └── prod/              # Prod applications (points to environments/prod)
│       └── guestbook.yaml
└── environments/          # Application manifests organized by environment
    ├── base/              # Base Kubernetes manifests
    │   ├── deployment.yaml
    │   ├── service.yaml
    │   └── kustomization.yaml
    ├── dev/               # Dev overlay (patches and replicas)
    │   ├── replica-patch.yaml
    │   └── kustomization.yaml
    └── prod/              # Prod overlay (patches and replicas)
        ├── replica-patch.yaml
        └── kustomization.yaml
```

## How It Works

This repository uses the **App-of-Apps** pattern:
1. The **Root Application** (in the `bootstrap/` folder) monitors the `apps/<env>/` folder.
2. Any ArgoCD Application manifest defined in `apps/<env>/` is automatically created in ArgoCD.
3. These environment-specific Applications in turn monitor and deploy the manifests defined under `environments/<env>/`.

```mermaid
graph TD
    classDef default fill:#f9f9f9,stroke:#333,stroke-width:1px;
    classDef root fill:#d4edda,stroke:#28a745,stroke-width:2px;
    classDef app fill:#cce5ff,stroke:#007bff,stroke-width:2px;
    classDef target fill:#fff3cd,stroke:#ffc107,stroke-width:2px;

    RootApp["Root Application<br>(bootstrap/dev-root.yaml)"]:::root
    AppsFolder["Apps Config Folder<br>(apps/dev/)"]
    AppGuestbook["Guestbook Application<br>(apps/dev/guestbook.yaml)"]:::app
    EnvFolder["Kustomize Target Overlay<br>(environments/dev/)"]
    TargetCluster["AKS Dev Cluster<br>(Namespace: dev)"]:::target

    RootApp -->|Monitors & Deploys| AppsFolder
    AppsFolder -->|Declares| AppGuestbook
    AppGuestbook -->|Monitors & Deploys| EnvFolder
    EnvFolder -->|Syncs Manifests| TargetCluster
```

---

## Bootstrapping ArgoCD

### 1. Dev Environment
To deploy all development applications, apply the Dev Root Application to your cluster:

```bash
kubectl apply -f bootstrap/dev-root.yaml
```

ArgoCD will automatically create the dev `guestbook` application and sync the resources defined in `environments/dev/` to the `dev` namespace.

### 2. Prod Environment
To deploy all production applications, apply the Prod Root Application to your cluster:

```bash
kubectl apply -f bootstrap/prod-root.yaml
```

ArgoCD will automatically create the prod `guestbook` application and sync the resources defined in `environments/prod/` to the `prod` namespace.

---

## Working with Kustomize

* **Base**: Common manifests (e.g. standard Deployment and Service definitions).
* **Overlays (Dev/Prod)**: Specific patches for each environment. For example, the `prod` overlay scales replicas to `3` and updates resource limits, while the `dev` overlay uses `1` replica and custom labels.

---

## Infrastructure Provisioning (Terraform)

The infrastructure for the AKS clusters is defined using Terraform. It is organized into a reusable module and cluster-specific directories to maintain separate state and configurations:

```text
terraform/
├── modules/
│   └── aks-gitops/          # Reusable module for RG, VNet, Subnet, AKS, ACR, and ArgoCD
└── clusters/
    ├── dev/                 # Dev environment cluster definition (1 node)
    └── prod/                # Prod environment cluster definition (3 nodes)
```

```mermaid
graph LR
    classDef default fill:#f9f9f9,stroke:#333,stroke-width:1px;
    classDef cluster fill:#e2e3e5,stroke:#383d41,stroke-width:2px;
    classDef acr fill:#cce5ff,stroke:#007bff,stroke-width:1px;
    
    subgraph Azure Subscription
        subgraph RG [Resource Group: rg-argocd-gitops-env]
            VNet["Virtual Network<br>(Azure CNI Subnet)"]
            ACR["Azure Container Registry (ACR)"]:::acr
            
            subgraph AKS [AKS Kubernetes Cluster]
                direction TB
                SystemPool["System Node Pool<br>(Standard_D2s_v3)"]
                
                subgraph ArgoNS [Namespace: argocd]
                    ArgoCD["Argo CD<br>(Helm Release)"]
                end
            end
        end
    end

    AKS -.->|Deployed inside| VNet
    AKS -->|Role: AcrPull| ACR
```

### Setup & Deployment

1. **Prerequisites**: Ensure you have Terraform installed, are logged into Azure (`az login`), and have selected the appropriate subscription.
2. **Initialize & Deploy (Dev)**:
   ```bash
   cd terraform/clusters/dev
   terraform init
   terraform apply
   ```
3. **Initialize & Deploy (Prod)**:
   ```bash
   cd terraform/clusters/prod
   terraform init
   terraform apply
   ```

> [!TIP]
> **Dynamic Providers Note**: Terraform configures the Helm/Kubernetes providers using the outputs of the AKS cluster. If applying for the first time on a clean environment, you should target the AKS infrastructure module first, then run a full apply to deploy Argo CD:
> ```bash
> terraform apply -target=module.aks_gitops
> terraform apply
> ```

### Connection & ArgoCD Access

Once Terraform apply completes, configure your local environment and retrieve your ArgoCD credentials:
1. **Configure kubectl**:
   ```bash
   # Run the command output by Terraform:
   az aks get-credentials --resource-group <resource_group> --name <cluster_name>
   ```
2. **Retrieve ArgoCD admin password**:
   - **Bash**: `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode`
   - **PowerShell**: `[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String((kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}")))`

---

## Architectural Decisions

### Networking: Azure CNI vs. Kubenet
This deployment defaults to **Azure CNI** (Container Network Interface) for native pod routing and performance.
* **Current Choice (Azure CNI)**: Every pod receives a real IP address from the VNet subnet. This enables direct, low-latency pod-to-pod communication across virtual networks and simplifies integration with other Azure services.
* **Future Consideration (Kubenet)**: Kubenet remains a future consideration to save IP address space. With Azure CNI, a cluster can quickly exhaust subnet IP space because each pod consumes a VNet IP. Kubenet uses IP address space inside the cluster node only and NATs traffic, meaning it only uses one host VNet IP per node. If VNet/Subnet IP address spaces become constrained, migrating to Kubenet networking is recommended.

