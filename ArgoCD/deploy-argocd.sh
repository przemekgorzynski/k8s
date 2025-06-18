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
ARGO_NODE_PORT_HTTP=30000
ARGO_NODE_PORT_HTTPS=30433
PROJECTS_FILES=("project-infrastructure.yml")

# Required environment variables
: "${BWS_ACCESS_TOKEN:?Environment variable BWS_ACCESS_TOKEN is required}"
: "${BWS_ORGANIZATION_ID:?Environment variable BWS_ORGANIZATION_ID is required}"
: "${BWS_PROJECT_ID:?Environment variable BWS_PROJECT_ID is required}"
: "${ARGO_ADMIN_PASS:?Environment variable ARGO_ADMIN_PASS is required}"

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
  --set server.service.nodePortHttps="$ARGO_NODE_PORT_HTTPS" \
  --set server.service.nodePortHttp="$ARGO_NODE_PORT_HTTP" \
  --set-string "configs.repositories.repo1.url=$ARGO_CONNECTED_REPO" \
  --set-string "configs.repositories.repo1.type=git" \
  --set-string "configs.repositories.repo1.name=connected-repo" \
  --set-string "configs.repositories.repo1.sshPrivateKey=$ARGO_SSH_PRIVATE_KEY" \
  --set configs.secret.argocdServerAdminPassword="$(htpasswd -nbBC 10 "" "$ARGO_ADMIN_PASS" | tr -d ':\n')"

# Wait for deployments to be ready
echo "⏳ Waiting for Argo CD deployments to be available..."
kubectl wait --for=condition=Available --timeout=${TIMEOUT_SECONDS}s \
  -n "$NAMESPACE" deployment -l app.kubernetes.io/instance=argocd

# Expose ArgoCD with additional ClusterIP service
echo "▶ Exposing ArgoCD with additional ClusterIP service"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: argocd-server-clusterip
  namespace: argocd
  labels:
    app.kubernetes.io/name: argocd-server
spec:
  type: ClusterIP
  selector:
    app.kubernetes.io/name: argocd-server
  ports:
    - name: http
      port: 80
      targetPort: 8080
EOF

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
# Apply ARGO Projects
# ────────────────────────────────────────────────────────────────────────────────
for file in "${PROJECTS_FILES[@]}"; do
  echo "Applying $file"
  kubectl apply -f "$file"
done

# ────────────────────────────────────────────────────────────────────────────────
# Apply ARGO Apps of Apps
# ────────────────────────────────────────────────────────────────────────────────
echo "⏳ Deploying Argo Apps of Apps"
kubectl apply -f ArgoCD-app-of-apps.yml

# Next steps
cat <<EOF

✅ Argo CD has been installed successfully in namespace '$NAMESPACE'.

🌐 Access the Argo CD UI:
    http://<NODE_IP>:$ARGO_NODE_PORT_HTTP
    https://<NODE_IP>:$ARGO_NODE_PORT_HTTPS

📁 Connected Git repo:
    $ARGO_CONNECTED_REPO

📦 App of Apps:
    App-of-apps will deploy, all applications defined in:
    ➤ $ARGO_CONNECTED_REPO

EOF
