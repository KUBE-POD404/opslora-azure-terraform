# Opslora observability dashboards

AzureRM creates Azure Managed Grafana and Azure Monitor alerts, but it does not import dashboard JSON into Grafana. Import the dashboard JSON after the Grafana endpoint and RBAC exist.

## Test dashboard

- File: `observability/grafana/opslora-test-aks-operations.dashboard.json`
- UID: `opslora-test-aks-operations`

## Prod dashboard

- File: `observability/grafana/opslora-prod-aks-operations.dashboard.json`
- UID: `opslora-prod-aks-operations`

Recommended prod import after Terraform apply:

```bash
az account set --subscription opslora-prod
az grafana folder create \
  -g rg-opslora-prod-monitoring-cin \
  -n amg-opslora-prod-cin-00 \
  --title Opslora || true
az grafana dashboard import \
  -g rg-opslora-prod-monitoring-cin \
  -n amg-opslora-prod-cin-00 \
  --folder Opslora \
  --overwrite true \
  --definition observability/grafana/opslora-prod-aks-operations.dashboard.json
```

The dashboard uses the Grafana 12 Azure Monitor query schema with `azureMonitor.resources[]` for metrics and `azureLogAnalytics.resources[]` for Log Analytics tables.

## Argo CD UI

No native Azure-managed Argo CD UI preview endpoint was found for the self-managed in-cluster Argo CD setup. Keep Argo private by default; use port-forwarding or design a private/SSO-gated ingress separately.
