# Opslora Azure private self-hosted runner

Purpose: run GitHub Actions jobs that must reach private Azure resources such as Key Vault private endpoints and private AKS endpoints.

Current required test runner labels:

```text
self-hosted
linux
x64
opslora-test
private-network
```

The `Azure Test Seed Secrets` workflow will not run on GitHub-hosted runners. This is intentional: Key Vault public access should stay disabled.

## Where to run it

Use an Ubuntu VM or host that is inside, peered to, or otherwise routed into the Opslora test private network and can resolve/reach:

```text
kv-opslora-test-cin-001.vault.azure.net
aks-opslora-test-cin-001 private endpoint / API endpoint
```

## Install/register runner

On the target VM, create a short-lived GitHub token with enough permission to create a runner registration token.

For org-level runner registration, the token needs org runner administration permission. With `gh`, this machine currently has `admin:org`; for another VM, use your own approved token/session.

Copy this repo script to the VM or run from a checkout:

```bash
cd /path/to/opslora-azure-terraform
sudo chmod +x scripts/install-github-runner.sh
sudo -E GITHUB_TOKEN="$GITHUB_TOKEN" \
  GITHUB_OWNER=KUBE-POD404 \
  RUNNER_NAME="opslora-test-private-$(hostname)" \
  RUNNER_LABELS="opslora-test,private-network" \
  ./scripts/install-github-runner.sh
```

For a repo-scoped runner instead of an org runner, add:

```bash
GITHUB_REPO=opslora-azure-terraform
```

The runner will automatically include built-in labels like `self-hosted`, `Linux`, and `X64`; the custom labels add `opslora-test` and `private-network`.

## Verify from Hermes/dev machine

```bash
gh api orgs/KUBE-POD404/actions/runners \
  --jq '.runners[] | [.name,.status,.busy,(.labels|map(.name)|join(","))] | @tsv'
```

or for repo-scoped runner:

```bash
gh api repos/KUBE-POD404/opslora-azure-terraform/actions/runners \
  --jq '.runners[] | [.name,.status,.busy,(.labels|map(.name)|join(","))] | @tsv'
```

## Then run Key Vault seed

Run GitHub Actions workflow manually:

```text
Workflow: Azure Test Seed Secrets
Branch: azure/hub-test-foundation
```

Expected behavior:

- workflow is picked up by the private runner
- Key Vault public network access is not toggled
- runtime app, RabbitMQ, notification, and Lora AI values are written to test Key Vault

## Troubleshooting

If the workflow sits queued:

- runner is offline
- labels do not match exactly
- runner is repo-scoped but workflow is looking for an org runner or vice versa
- runner service failed; check on VM with:

```bash
sudo /opt/actions-runner/svc.sh status
sudo journalctl -u actions.runner.* --no-pager -n 200
```

If Key Vault seeding fails with DNS or timeout:

- runner cannot resolve the private endpoint DNS
- VNet peering/private DNS zone link is missing
- firewall/NSG route blocks outbound to private endpoint

If Key Vault seeding fails with RBAC:

- the Azure workload identity/service principal used by `AZURE_TEST_CLIENT_ID` lacks Key Vault Secrets Officer/appropriate secret permissions on `kv-opslora-test-cin-001`
- role assignment propagation may need a few minutes
