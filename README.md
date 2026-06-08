# Opslora Azure Terraform

Terraform landing zone for Opslora on Azure.

Current deployment scope:

- Hub/connectivity subscription.
- Test spoke subscription.

Out of scope for the first implementation:

- Production apply.
- Production DR apply.
- Azure Firewall, VPN Gateway, Bastion, and DNS Private Resolver enablement by default.

## Workspaces

| Workspace | Purpose |
| --- | --- |
| `platform` | Hub/connectivity foundation |
| `test` | Test spoke foundation |

## Environments

```text
environments/platform
environments/test
```

## Bootstrap Order

1. Create or select the `platform` workspace.
2. Bootstrap Terraform state storage.
3. Apply `environments/platform`.
4. Create or select the `test` workspace.
5. Apply `environments/test`.

## Key Decisions

- Region: Central India, `centralindia`.
- AKS networking: Azure CNI Overlay.
- Ingress: Application Gateway WAF v2 + AGIC add-on.
- Images: GHCR, not ACR.
- Database: Azure Database for MySQL Flexible Server.
- MySQL network mode: Private access with VNet integration on a delegated subnet.
- Private DNS: centralized in the hub subscription.

## Required Variables

Copy the example tfvars files and fill in subscription IDs.

```powershell
Copy-Item environments/platform/platform.tfvars.example environments/platform/platform.auto.tfvars
Copy-Item environments/test/test.tfvars.example environments/test/test.auto.tfvars
```

Do not commit real `*.tfvars` or `*.auto.tfvars` files.

