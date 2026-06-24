# Opslora hub on-prem AI VPN inputs

This hub environment already supports Azure Local Network Gateway + IPsec connection creation through:

```text
onprem_sites
onprem_shared_keys
onprem_private_dns_zone_name
onprem_a_records
```

Use this for the OPNsense on-prem AI VLAN path.

## Chosen on-prem contract

```text
Firewall/router: OPNsense dedicated appliance
AI VLAN ID: 110
AI VLAN CIDR: 172.16.10.0/24
OPNsense gateway: 172.16.10.1
Hermes AI host: 172.16.10.10
Private DNS: ai-gateway.onprem.opslora.internal
```

Azure should learn only:

```text
172.16.10.0/24
```

Do not advertise the home/broadband network:

```text
192.168.29.0/24
```

## Azure peer

Current hub VPN gateway public IP:

```text
4.188.98.24
```

OPNsense should use this as the Azure peer for site-to-site IPsec/IKEv2.

## Before applying

Do not apply non-empty `onprem_sites` until all are true:

```text
OPNsense WAN public IP or stable DDNS is known
OPNsense VLAN 110 exists as 172.16.10.1/24
Hermes Ethernet/VLAN is active as 172.16.10.10/24
OPNsense can reach 172.16.10.10
A secure IPsec PSK has been generated and stored outside git
```

## Example

Use the non-secret example file:

```text
environments/hub/examples/onprem-ai-vpn.auto.tfvars.example
```

Copy it to a secure, untracked tfvars location and replace placeholders.

Real PSKs must not be committed. Supply `onprem_shared_keys` via secure tfvars or GitHub Actions secrets/environment variables.

## Expected Terraform resources

For site key `ai-trivandrum`, Terraform creates:

```text
Local Network Gateway:
lgw-opslora-ai-trivandrum-cin-001

VPN connection:
cn-opslora-hub-ai-trivandrum-cin-001

Private DNS zone if records are set:
onprem.opslora.internal

A record:
ai-gateway.onprem.opslora.internal -> 172.16.10.10
```

## Validation after apply

```bash
az network vpn-connection show \
  --subscription 2879c873-3751-40c2-b43a-ba4c1198ba89 \
  --resource-group rg-opslora-hub-connectivity-cin \
  --name cn-opslora-hub-ai-trivandrum-cin-001 \
  --query '{status:connectionStatus,egress:egressBytesTransferred,ingress:ingressBytesTransferred}'
```

Then run the AKS path check from `opslora-platform-devops`:

```bash
NAMESPACE=opslora-app-ns \
TARGET_URL=http://ai-gateway.onprem.opslora.internal:8080/health \
/home/sks/opslora/opslora-platform-devops/scripts/aks_onprem_ai_healthcheck.sh
```
