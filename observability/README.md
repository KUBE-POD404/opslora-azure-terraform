# Opslora Argo CD UI and Observability Notes

## Argo CD UI feasibility

The current test cluster runs self-managed Argo CD in the `argocd` namespace. The `argocd-server` Service is currently `ClusterIP` only, which is the safest default.

Azure CLI/provider discovery in the test subscription did not show a native Azure-managed Argo CD UI preview extension/resource for this AKS cluster. The available Azure-native GitOps resources are Flux-oriented (`azurerm_kubernetes_flux_configuration` / Kubernetes extensions), not a managed Argo CD UI endpoint.

Therefore, do not expose Argo CD publicly as a quick fix. The safe options are:

1. Private/operator access only:
   - keep `argocd-server` internal
   - use `kubectl port-forward -n argocd svc/argocd-server 8080:443` from an authenticated operator machine
   - optionally add a private DNS name reachable only over VPN/Tailscale/private network

2. Controlled ingress later:
   - create a dedicated test hostname such as `argocd-test.opslora.com`
   - expose through AGIC/App Gateway with TLS
   - require Argo CD SSO/RBAC before broad use
   - restrict network access where possible
   - manage Kubernetes objects through either the Helm/GitOps repo or a Terraform Kubernetes provider only after the test Terraform workflow has explicit AKS credentials

This Terraform change intentionally does not create a public Argo CD ingress.

## Grafana dashboard provisioning

Terraform enables Azure Managed Grafana and connects it to the Azure Monitor workspace. The dashboard JSON in this folder is the initial Opslora test AKS operations dashboard.

After the Managed Grafana endpoint exists, import this JSON into Azure Managed Grafana or add the Grafana provider once an approved service-account/auth path is selected.

Initial dashboard file:

- `observability/grafana/opslora-test-aks-operations.dashboard.json`

## Alerts created by Terraform

The test Terraform module creates:

- AKS node CPU > 85% for 15m
- AKS node memory working set > 90% for 15m
- AKS node disk > 90% for 15m
- unschedulable pods > 0 for 10m
- workload restarts in `opslora-app-ns` or `argocd`
- failed/pending/unknown pods in `opslora-app-ns` or `argocd`

Email receivers are optional through `var.alert_email_receivers`. Leaving it empty still creates the action group and alert rules; receivers can be added later without changing alert definitions.
