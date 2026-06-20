#!/usr/bin/env bash
set -euo pipefail

# Install and register a GitHub Actions self-hosted runner on an Ubuntu VM.
# Intended for Opslora private-network runners that can reach private Azure
# resources such as Key Vault private endpoints and AKS private endpoints.
#
# Required environment variables:
#   GITHUB_TOKEN       token with admin:org for org runner, or repo admin for repo runner
# Optional environment variables:
#   GITHUB_OWNER       default: KUBE-POD404
#   GITHUB_REPO        if set, registers a repo runner; otherwise org runner
#   RUNNER_NAME        default: <hostname>-opslora-test
#   RUNNER_LABELS      default: opslora-test,private-network
#   RUNNER_GROUP       optional runner group for org runners
#   RUNNER_VERSION     default: latest from GitHub API
#   RUNNER_USER        default: actions-runner
#   RUNNER_ROOT        default: /opt/actions-runner

GITHUB_OWNER="${GITHUB_OWNER:-KUBE-POD404}"
GITHUB_REPO="${GITHUB_REPO:-}"
RUNNER_NAME="${RUNNER_NAME:-$(hostname)-opslora-test}"
RUNNER_LABELS="${RUNNER_LABELS:-opslora-test,private-network}"
RUNNER_GROUP="${RUNNER_GROUP:-}"
RUNNER_USER="${RUNNER_USER:-actions-runner}"
RUNNER_ROOT="${RUNNER_ROOT:-/opt/actions-runner}"
ARCH="${ARCH:-x64}"

if [[ -z "${GITHUB_TOKEN:-}" ]]; then
  echo "GITHUB_TOKEN is required" >&2
  exit 2
fi

if [[ "$EUID" -ne 0 ]]; then
  echo "Run as root, e.g. sudo -E $0" >&2
  exit 2
fi

apt-get update
apt-get install -y curl jq tar ca-certificates git libicu-dev

if ! id -u "$RUNNER_USER" >/dev/null 2>&1; then
  useradd --system --create-home --shell /bin/bash "$RUNNER_USER"
fi

mkdir -p "$RUNNER_ROOT"
chown "$RUNNER_USER:$RUNNER_USER" "$RUNNER_ROOT"

if [[ -n "$GITHUB_REPO" ]]; then
  SCOPE_URL="https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}"
  TOKEN_API="https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPO}/actions/runners/registration-token"
else
  SCOPE_URL="https://github.com/${GITHUB_OWNER}"
  TOKEN_API="https://api.github.com/orgs/${GITHUB_OWNER}/actions/runners/registration-token"
fi

REG_TOKEN="$(
  curl -fsSL -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${GITHUB_TOKEN}" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "$TOKEN_API" | jq -r '.token'
)"

if [[ -z "$REG_TOKEN" || "$REG_TOKEN" == "null" ]]; then
  echo "Failed to obtain GitHub runner registration token" >&2
  exit 1
fi

if [[ "${RUNNER_VERSION:-latest}" == "latest" ]]; then
  RUNNER_VERSION="$(
    curl -fsSL https://api.github.com/repos/actions/runner/releases/latest | jq -r '.tag_name | sub("^v"; "")'
  )"
fi

RUNNER_TGZ="actions-runner-linux-${ARCH}-${RUNNER_VERSION}.tar.gz"
RUNNER_URL="https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/${RUNNER_TGZ}"

sudo -u "$RUNNER_USER" bash -lc "cd '$RUNNER_ROOT' && curl -fsSLO '$RUNNER_URL' && tar xzf '$RUNNER_TGZ'"

CONFIG_ARGS=(
  --url "$SCOPE_URL"
  --token "$REG_TOKEN"
  --name "$RUNNER_NAME"
  --labels "$RUNNER_LABELS"
  --work "_work"
  --unattended
  --replace
)

if [[ -n "$RUNNER_GROUP" ]]; then
  CONFIG_ARGS+=(--runnergroup "$RUNNER_GROUP")
fi

sudo -u "$RUNNER_USER" bash -lc "cd '$RUNNER_ROOT' && ./config.sh ${CONFIG_ARGS[*]@Q}"

"$RUNNER_ROOT/svc.sh" install "$RUNNER_USER"
"$RUNNER_ROOT/svc.sh" start
"$RUNNER_ROOT/svc.sh" status

echo "Registered GitHub Actions runner: $RUNNER_NAME"
echo "Scope: $SCOPE_URL"
echo "Labels include built-ins self-hosted/linux/$ARCH plus custom: $RUNNER_LABELS"
