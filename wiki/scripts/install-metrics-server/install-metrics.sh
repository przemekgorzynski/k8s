#!/bin/bash

set -e

# Define versions
METRIC_SERVER_VER="v0.7.2"
KSM_REPO="https://github.com/kubernetes/kube-state-metrics.git"
KSM_DIR="kube-state-metrics"

echo "📦 Installing metrics-server..."
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/${METRIC_SERVER_VER}/components.yaml

echo "🔧 Patching metrics-server for self-managed cluster compatibility..."
kubectl patch deployment metrics-server -n kube-system \
  --type='json' \
  -p='[
    {
      "op": "add",
      "path": "/spec/template/spec/containers/0/args/-",
      "value": "--kubelet-insecure-tls"
    },
    {
      "op": "add",
      "path": "/spec/template/spec/containers/0/args/-",
      "value": "--kubelet-preferred-address-types=InternalIP,Hostname,ExternalIP"
    }
  ]'

echo "📥 Cloning kube-state-metrics repository..."
if [ -d "$KSM_DIR" ]; then
  echo "📁 Directory $KSM_DIR already exists. Removing..."
  rm -rf "$KSM_DIR"
fi

git clone --depth=1 "$KSM_REPO"

echo "📦 Installing kube-state-metrics using kustomize..."
kubectl apply -k "${KSM_DIR}/examples/standard"

echo "🧹 Cleaning up..."
rm -rf "$KSM_DIR"

echo "✅ Installation complete."

echo -e "\n💡 Useful commands:"
echo "kubectl top nodes"
echo "kubectl get pods -n kube-system -l app.kubernetes.io/name=kube-state-metrics"
