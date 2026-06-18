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

## GitHub Actions Terraform Pipelines

Terraform is intended to run from GitHub Actions for the hub and test roots so the
operator laptop does not need local provider mirrors or long-lived Azure secrets.

Workflows:

| Workflow | Trigger | Root | Purpose |
| --- | --- | --- | --- |
| `Azure Hub Terraform Plan` | pull request or manual | `environments/hub` | Formats, initializes, validates, and uploads a hub plan artifact. |
| `Azure Hub Terraform Apply` | manual only | `environments/hub` | Re-plans and applies hub changes after typed confirmation. |
| `Azure Test Terraform Plan` | pull request, manual, or after successful hub apply | `environments/test` | Formats, initializes, validates, and uploads a test plan artifact. |
| `Azure Test Terraform Apply` | manual only | `environments/test` | Re-plans and applies test changes after typed confirmation. |

Apply workflows require a typed confirmation:

- Hub apply: `apply-hub`
- Test apply: `apply-test`

Apply workflows are restricted to the `azure/hub-test-foundation` branch and
require typed confirmation. The test plan workflow also runs automatically after
a successful hub apply because the test root depends on hub remote-state outputs.

Azure RBAC requirements:

- `AZURE_HUB_CLIENT_ID` needs enough access in `opslora-connectivity` to manage
  the hub root and read/write `platform/terraform.tfstate`.
- `AZURE_TEST_CLIENT_ID` needs enough access in `opslora-test` to manage the
  test root.
- `AZURE_TEST_CLIENT_ID` also needs hub-side access to read the remote hub state
  blob and manage the hub-to-test peering plus Private DNS VNet links, because
  `environments/test` uses an `azurerm.hub` provider alias.

Governance policy note:

- Governance policy assignments are enabled by default.
- The Terraform identities need permission for
  `Microsoft.Authorization/policyDefinitions/write` and
  `Microsoft.Authorization/policyAssignments/write`.
- Current rollout grants `Resource Policy Contributor` to the hub and test
  Terraform identities at their subscription scopes.

Recommended first run order:

1. Run `Azure Hub Terraform Plan`.
2. Review the uploaded `hub-tfplan-*` artifact.
3. Run `Azure Hub Terraform Apply` with `apply-hub`.
4. Wait for the automatic `Azure Test Terraform Plan` run.
5. Review the uploaded `test-tfplan-*` artifact.
6. Run `Azure Test Terraform Apply` with `apply-test`.

The workflows pin Terraform CLI to `1.12.2`. If provider lock files need to be
refreshed, do it in a clean runner/VM and commit the updated lock files with
checksums for Linux runners.
