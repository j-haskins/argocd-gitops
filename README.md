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
