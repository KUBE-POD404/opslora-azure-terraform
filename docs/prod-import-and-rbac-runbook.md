# Opslora Prod Import And RBAC Runbook

This runbook is for the prod and prod-dr Terraform roots.

## Entra Groups

Create or identify these Microsoft Entra groups before enabling Terraform RBAC assignments:

| Group | Scope |
| --- | --- |
| `opslora-network-admins` | Prod and DR network resource groups |
| `opslora-dns-admins` | Hub DNS resource group and Azure DNS zones |
| `opslora-security-admins` | Prod and DR Key Vault/security resource groups |
| `opslora-data-admins` | Prod and DR data resource groups |
| `opslora-aks-admins-prod` | Prod and DR AKS cluster admin access |
| `opslora-observability-admins` | Prod and DR monitoring resource groups |
| `opslora-release-managers-prod` | Prod release/deployment operations |
| `opslora-breakglass-admins` | Emergency subscription Owner, preferably through PIM |

Keep `enable_rbac_assignments = false` until all group object IDs are known and reviewed.

## Terraform Roots

Use separate state keys:

| Root | State key |
| --- | --- |
| `environments/prod` | `prod/terraform.tfstate` |
| `environments/prod-dr` | `prod-dr/terraform.tfstate` |

Prod deploys Central India resources. Prod DR deploys South India standby resources in the prod subscription.

## Import Flow

1. Fill a local, uncommitted tfvars file from `prod.tfvars.example` or `prod-dr.tfvars.example`.
2. Run `terraform init`.
3. Add import blocks or run `terraform import` for any resources that already exist.
4. Run `terraform plan` and confirm the first plan is import-only or creates only approved missing resources.
5. Enable `enable_rbac_assignments = true` only after group object IDs are present.
6. Keep prod policy effects in `Deny`; temporarily use `Audit` only through an approved exception.

## Replication Notes

Prod MySQL is configured with 35-day backups, geo-redundant backup enabled, and zone-redundant HA. Prod DR has the South India network and data landing zone ready for a restore or replica target. Do not put MySQL admin passwords or application secrets in tfvars; bootstrap runtime secrets into Key Vault after the vault exists.

Key Vault secrets should be recovered or synchronized through an approved pipeline/runbook, not copied through Terraform variables, because Terraform state can retain secret values.
