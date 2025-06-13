#!/usr/bin/env bash
set -euo pipefail

# Configuration
NAMESPACE="argocd"
MANIFEST_URL="https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
TIMEOUT_SECONDS=300
SLEEP_INTERVAL=5

# Check for kubectl
if ! command -v kubectl &> /dev/null; then
  echo "[ERROR] kubectl not found. Please install and configure access to your cluster." >&2
  exit 1
fi

# Create namespace if it doesn't exist
if kubectl get namespace "$NAMESPACE" &> /dev/null; then
  echo "Namespace '$NAMESPACE' already exists."
else
  echo "Creating namespace '$NAMESPACE'..."
  kubectl create namespace "$NAMESPACE"
  echo "Namespace '$NAMESPACE' created."
fi

# Apply Argo CD manifests
echo "Installing Argo CD into namespace '$NAMESPACE'..."
kubectl apply -n "$NAMESPACE" -f "$MANIFEST_URL"
echo "Manifests applied."

# Expose Argo CD server via NodePort
echo "Patching argocd-server service to type NodePort..."
kubectl patch svc argocd-server -n "$NAMESPACE" -p '{"spec":{"type":"NodePort"}}'
NODE_PORT=$(kubectl get svc argocd-server -n "$NAMESPACE" -o jsonpath='{.spec.ports[?(@.port==443)].nodePort}')
echo "Argo CD Server available on NodePort: $NODE_PORT"

# Wait for deployments to be ready
echo "Waiting for Argo CD components to be ready (timeout: ${TIMEOUT_SECONDS}s)..."
end_time=$((SECONDS + TIMEOUT_SECONDS))
while true; do
  not_ready=$(kubectl -n "$NAMESPACE" get deploy \
    -l app.kubernetes.io/instance=argocd \
    -o jsonpath='{range .items[*]}{.metadata.name}:{.status.availableReplicas}/{.spec.replicas}\n{end}' \
    | awk -F: '$2 !~ /^[0-9]+\/[0-9]+$/ {print $0}')
  if [[ -z "$not_ready" ]]; then
    echo "All deployments are available."
    break
  fi

  if (( SECONDS >= end_time )); then
    echo "[ERROR] Timeout waiting for deployments to be ready:" >&2
    echo "$not_ready" >&2
    exit 1
  fi

  echo "Still waiting for:"
  echo "$not_ready"
  sleep "$SLEEP_INTERVAL"
done

# Print next steps
cat <<EOF

Argo CD has been installed successfully in namespace '$NAMESPACE'.

Next steps:
- To access the UI via NodePort on any cluster node address:
    http://<NODE_IP>:$NODE_PORT

- Retrieve the admin password:
    kubectl -n argocd get secret argocd-initial-admin-secret \
      -o jsonpath='{.data.password}' | base64 --decode

EOF
