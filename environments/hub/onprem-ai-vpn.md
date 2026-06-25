# Opslora hub on-prem AI VPN inputs

Status: superseded/inactive as of 2026-06-25.

Opslora currently uses the temporary Tailscale AKS bridge for Azure-to-local AI connectivity instead of Azure native S2S VPN.

Active bridge reference:

```text
opslora-platform-devops/docs/azure-plans/20260625-architecture-shift-tailscale-ai-bridge.md
opslora-platform-devops/docs/azure-plans/20260625-azure-aks-tailscale-temporary-ai-bridge.md
```

## Current Terraform posture

The hub VPN stack is disabled by default:

```text
enable_vpn_gateway = false
```

When disabled, Terraform does not create:

```text
Azure VPN Gateway
VPN Gateway public IP
Azure Local Network Gateway
Azure VPN Connection
```

This intentionally removes the previous unused VPN resources:

```text
vpngw-opslora-hub-cin-001
pip-opslora-vpngw-cin-001
```

## Historical/permanent design only

The previous permanent design was:

```text
Firewall/router: OPNsense dedicated appliance
AI VLAN ID: 110
AI VLAN CIDR: 172.16.10.0/24
OPNsense gateway: 172.16.10.1
Hermes AI host: 172.16.10.10
Private DNS: ai-gateway.onprem.opslora.internal
```

That design is not active. Do not re-enable it unless the user explicitly chooses to restore the OPNsense/VLAN/IPsec path.

## If the VPN path is restored later

Only set `enable_vpn_gateway = true` and non-empty `onprem_sites` after all are true:

```text
OPNsense/firewall hardware exists
OPNsense WAN public IP or stable DDNS is known
OPNsense VLAN 110 exists as 172.16.10.1/24
Hermes Ethernet/VLAN is active as 172.16.10.10/24
OPNsense can reach 172.16.10.10
A secure IPsec PSK has been generated and stored outside git
```

Optional future site definitions remain supported by these variables:

```text
enable_vpn_gateway
onprem_sites
onprem_shared_keys
onprem_private_dns_zone_name
onprem_a_records
```

Real PSKs must not be committed. Supply `onprem_shared_keys` via secure tfvars or GitHub Actions secrets/environment variables.
