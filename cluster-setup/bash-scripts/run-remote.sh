#!/bin/bash
set -euo pipefail

REMOTE_USER="przemek"
REMOTE_HOST="10.0.0.9"
REMOTE_DIR="/tmp"

DEPLOY_SCRIPT="setup-k8s-master.sh"
CLEANUP_SCRIPT="cleanup-cluster.sh"
CONFIG_NAME="kubeadm-config.yml"

# 🧪 Validate argument
if [[ $# -ne 1 || ! "$1" =~ ^(deploy|cleanup|redeploy)$ ]]; then
  echo "❌ Usage: $0 [deploy|cleanup|redeploy]"
  exit 1
fi

ACTION=$1

function wait_for_ssh() {
  echo "⏳ Checking if ${REMOTE_HOST} is reachable..."
  sleep 10
  until ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no "${REMOTE_USER}@${REMOTE_HOST}" 'echo "✅ Node is reachable."' 2>/dev/null; do
    sleep 5
  done
}

if [[ "$ACTION" == "deploy" ]]; then
  echo "🚚 Copying deployment files to ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}..."
  scp "$DEPLOY_SCRIPT" "$CONFIG_NAME" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/"

  echo "🚀 Running deployment script remotely..."
  ssh "${REMOTE_USER}@${REMOTE_HOST}" "cd ${REMOTE_DIR} && chmod +x ${DEPLOY_SCRIPT} && sudo ./${DEPLOY_SCRIPT}" || true
  wait_for_ssh

elif [[ "$ACTION" == "cleanup" ]]; then
  echo "🚚 Copying cleanup script to ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}..."
  scp "$CLEANUP_SCRIPT" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/"

  echo "🧹 Running cleanup script remotely..."
  ssh "${REMOTE_USER}@${REMOTE_HOST}" "cd ${REMOTE_DIR} && chmod +x ${CLEANUP_SCRIPT} && sudo ./${CLEANUP_SCRIPT}"

elif [[ "$ACTION" == "redeploy" ]]; then
  echo "♻️ Starting redeploy: cleanup → deploy..."
  echo ""

  echo "🧹 Cleaning up existing cluster..."
  "$0" cleanup

  echo ""
  echo "🚀 Deploying fresh cluster..."
  "$0" deploy
fi
