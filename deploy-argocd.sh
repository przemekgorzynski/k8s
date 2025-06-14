#!/usr/bin/env bash
set -euo pipefail

# shorthand for kubectl
k() { kubectl "$@"; }

# Configuration
NAMESPACE="argocd"
TIMEOUT_SECONDS=300
SLEEP_INTERVAL=5
ARGO_CONNECTED_REPO="git@github.com:przemekgorzynski/ArgoCDApps.git"
ARGO_SSH_PRIVATE_KEY="$(cat ~/.ssh/id_ed25519)"
ARGO_NODE_PORT=32000

# Required environment variables
: "${BWS_ACCESS_TOKEN:?Environment variable BWS_ACCESS_TOKEN is required}"
: "${BWS_ORGANIZATION_ID:?Environment variable BWS_ORGANIZATION_ID is required}"
: "${BWS_PROJECT_ID:?Environment variable BWS_PROJECT_ID is required}"

# Create namespace if it doesn't exist
if kubectl get namespace "$NAMESPACE" &> /dev/null; then
  echo "Namespace '$NAMESPACE' already exists."
else
  echo "Creating namespace '$NAMESPACE'..."
  kubectl create namespace "$NAMESPACE"
  echo "Namespace '$NAMESPACE' created."
fi

# Add Argo Helm repo
echo "▶ Adding Argo Helm repo..."
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Base64-encode SSH key for Helm set
ENCODED_SSH_KEY=$(echo "$ARGO_SSH_PRIVATE_KEY" | base64 -w0)

# Install Argo CD with SSH Git repo connected
echo "▶ Installing Argo CD with SSH Git repository connection..."
helm upgrade --install argocd argo/argo-cd \
  --namespace "$NAMESPACE" \
  --create-namespace \
  --set server.service.type=NodePort \
  --set server.service.nodePortHttps="$ARGO_NODE_PORT" \
  --set-string "configs.repositories.repo1.url=$ARGO_CONNECTED_REPO" \
  --set-string "configs.repositories.repo1.type=git" \
  --set-string "configs.repositories.repo1.name=connected-repo" \
  --set-string "configs.repositories.repo1.sshPrivateKey=$ARGO_SSH_PRIVATE_KEY"

# Wait for deployments to be ready
echo "⏳ Waiting for Argo CD deployments to be available..."
kubectl wait --for=condition=Available --timeout=${TIMEOUT_SECONDS}s \
  -n "$NAMESPACE" deployment -l app.kubernetes.io/instance=argocd


# ────────────────────────────────────────────────────────────────────────────────
# Create Bitwarden secrets for External Secrets Operator
# ────────────────────────────────────────────────────────────────────────────────
echo "▶ Ensuring namespace external-secrets exists…"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: external-secrets
EOF

echo "▶ Creating Bitwarden secret with token, organizationId, and projectId..."
kubectl create secret generic bitwarden-credentials \
  --from-literal=token="${BWS_ACCESS_TOKEN}" \
  --from-literal=organizationId="${BWS_ORGANIZATION_ID}" \
  --from-literal=projectId="${BWS_PROJECT_ID}" \
  -n external-secrets --dry-run=client -o yaml | kubectl apply -f -

# ────────────────────────────────────────────────────────────────────────────────
# Deploy App of Apps root application
# ────────────────────────────────────────────────────────────────────────────────
echo "▶ Deploying App of Apps root Application..."

cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: root-app
  namespace: $NAMESPACE
spec:
  project: default
  source:
    repoURL: $ARGO_CONNECTED_REPO
    targetRevision: HEAD
    path: infrastructure-project
  destination:
    server: https://kubernetes.default.svc
    namespace: $NAMESPACE
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF


# Next steps
cat <<EOF

✅ Argo CD has been installed successfully in namespace '$NAMESPACE'.

🌐 Access the Argo CD UI:
    http://<NODE_IP>:$ARGO_NODE_PORT

🔑 Retrieve the admin password:
    kubectl -n argocd get secret argocd-initial-admin-secret \
      -o jsonpath='{.data.password}' | base64 --decode

📁 Connected Git repo:
    $ARGO_CONNECTED_REPO

📦 App of Apps:
    root-app will deploy all applications defined in:
    ➤ $ARGO_CONNECTED_REPO/infrastructure-project

EOF
