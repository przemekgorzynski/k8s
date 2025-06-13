#!/usr/bin/env bash
set -euo pipefail
# Exit immediately on error, treat unset variables as errors, and fail on any pipe step

# shorthand for kubectl
k() { kubectl "$@"; }

# ────────────────────────────────────────────────────────────────────────────────
# Preparation: validate required environment variables
#   Ensures Bitwarden credentials and IDs are provided before proceeding
# ────────────────────────────────────────────────────────────────────────────────
echo "▶ Validating environment variables..."
if [[ -z "${BWS_ACCESS_TOKEN:-}" || -z "${BWS_ORGANIZATION_ID:-}" || -z "${BWS_PROJECT_ID:-}" ]]; then
  echo "❌ Missing one of: BWS_ACCESS_TOKEN, BWS_ORGANIZATION_ID, BWS_PROJECT_ID"
  exit 1
fi
echo "✅ Environment variables validated."


# ────────────────────────────────────────────────────────────────────────────────
# Create Bitwarden access-token secret
# ────────────────────────────────────────────────────────────────────────────────
echo "▶ Ensuring namespace external-secrets exists…"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: external-secrets
EOF

echo "▶ Creating Bitwarden access-token secret..."
k create secret generic bitwarden-access-token \
  --from-literal=token="${BWS_ACCESS_TOKEN}" \
  -n external-secrets --dry-run=client -o yaml | kubectl apply -f -

# ────────────────────────────────────────────────────────────────────────────────
# 1) Apply AppProject 'infrastructure'
#    Defines allowed Git repos, destinations, and cluster-scoped resources
# ────────────────────────────────────────────────────────────────────────────────
echo "▶ Applying AppProject 'infrastructure'..."
k apply -n argocd -f argocd-apps/project-infrastructure.yml

echo "✅ AppProject applied."

# ────────────────────────────────────────────────────────────────────────────────
# 2) Deploy Local Path Provisioner
#    Creates a storage class and marks it default in 'local-path-storage'
# ────────────────────────────────────────────────────────────────────────────────
echo "▶ Deploying Local Path Provisioner..."
k apply -n argocd -f argocd-apps/local-path-provisioner.yml

echo "✅ local-path-provisioner applied."

# ────────────────────────────────────────────────────────────────────────────────
# 3) Deploy Cert-Manager
#    Installs cert-manager chart (with CRDs) into 'cert-manager'
# ────────────────────────────────────────────────────────────────────────────────
echo "▶ Deploying Cert-Manager..."
k apply -n argocd -f argocd-apps/cert-manager.yml

echo "✅ cert-manager applied."

# ────────────────────────────────────────────────────────────────────────────────
# 5) Deploy External-Secrets Operator
#    Installs operator with Bitwarden SDK server enabled
# ────────────────────────────────────────────────────────────────────────────────
echo "▶ Deploying External-Secrets Operator..."
k apply -f argocd-apps/external-secrets-operator/external-secret-operator.yml

echo "✅ external-secrets-operator applied."

# ────────────────────────────────────────────────────────────────────────────────
echo "🎉 Bootstrap completed. All Argo CD applications and prerequisites have been registered."
