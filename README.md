# Opslora Azure Terraform

Terraform landing zone for Opslora on Azure.

Current deployment scope:

- Hub/connectivity subscription.
- Test spoke subscription.

Out of scope for the first implementation:

- Production apply.
- Production DR apply.
- Azure Firewall, VPN Gateway, Bastion, and DNS Private Resolver enablement by default.

## Environment Roots

Opslora uses separate Terraform root modules per Azure scope/environment, with separate remote state keys. Do not use `terraform workspace` for the hub/test rollout.

| Root | Purpose | State key |
| --- | --- |
| `environments/hub` | Hub/connectivity foundation | `platform/terraform.tfstate` |
| `environments/test` | Test spoke foundation | `test/terraform.tfstate` |

## Environments

```text
environments/hub
environments/test
```

## Bootstrap Order

1. Bootstrap Terraform state storage.
2. Apply `environments/hub`.
3. Apply `environments/test`.

Run Terraform from the environment folder you intend to manage:

```powershell
cd environments/hub
terraform init
terraform plan

cd ../test
terraform init
terraform plan
```

Each root points to its own backend key, so test changes cannot accidentally write to the hub state.

Note: the hub root intentionally keeps the existing `platform/terraform.tfstate` key for now because the first hub deployment already used that state path. Rename it to `hub/terraform.tfstate` only after copying/migrating the existing state blob.

## Key Decisions

- Region: Central India, `centralindia`.
- AKS networking: Azure CNI Overlay.
- Ingress: Application Gateway WAF v2 + AGIC add-on.
- Images: GHCR, not ACR.
- Database: Azure Database for MySQL Flexible Server.
- MySQL network mode: Private access with VNet integration on a delegated subnet.
- Private DNS: centralized in the hub subscription.

## Required Variables

For local runs, copy the example tfvars files and fill in subscription IDs.

```powershell
Copy-Item environments/hub/hub.tfvars.example environments/hub/hub.auto.tfvars
Copy-Item environments/test/test.tfvars.example environments/test/test.auto.tfvars
```

Do not commit real `*.tfvars` or `*.auto.tfvars` files.

For GitHub Actions, configure these repository or environment secrets:

| Secret | Used by |
| --- | --- |
| `AZURE_TENANT_ID` | Hub and test Terraform login/provider |
| `AZURE_HUB_CLIENT_ID` | Hub Terraform OIDC identity |
| `AZURE_HUB_SUBSCRIPTION_ID` | Hub/connectivity subscription |
| `AZURE_TEST_CLIENT_ID` | Test Terraform OIDC identity |
| `AZURE_TEST_SUBSCRIPTION_ID` | Test subscription |
| `AZURE_AKS_SSH_PUBLIC_KEY` | Test AKS Linux profile |
