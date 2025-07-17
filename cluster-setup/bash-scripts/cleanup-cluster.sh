#!/bin/bash
set -euo pipefail

echo "🔍 Checking if Kubernetes is running on this node..."
if ! command -v kubeadm >/dev/null 2>&1 && [ ! -d /etc/kubernetes ] && [ ! -d /var/lib/kubelet ]; then
  echo "✅ Kubernetes is not installed or already removed. Skipping cleanup."
  exit 0
fi

echo "⚠️  [1/9] Resetting kubeadm cluster..."
if command -v kubeadm >/dev/null 2>&1; then
  sudo kubeadm reset --cri-socket /run/containerd/containerd.sock --force >/dev/null 2>&1 || true
fi

echo "🧹 [2/9] Cleaning up Kubernetes pods and containers (crictl)..."
if command -v crictl >/dev/null 2>&1 && [ -S /run/containerd/containerd.sock ]; then
  sudo crictl stopp -a >/dev/null 2>&1 || true
  sudo crictl rmp -a >/dev/null 2>&1 || true
  sudo crictl rm -fa >/dev/null 2>&1 || true
fi

echo "🧹 [3/9] Cleaning up residual containerd resources (ctr)..."
if command -v ctr >/dev/null 2>&1 && [ -S /run/containerd/containerd.sock ]; then
  CONTAINERS=$(sudo ctr -n k8s.io containers list | awk 'NR>1 {print $1}')
  if [ -n "$CONTAINERS" ]; then
    echo "$CONTAINERS" | xargs -r sudo ctr -n k8s.io containers delete >/dev/null 2>&1 || true
  fi
  SNAPSHOTS=$(sudo ctr -n k8s.io snapshots list | awk 'NR>1 {print $1}')
  if [ -n "$SNAPSHOTS" ]; then
    echo "$SNAPSHOTS" | xargs -r sudo ctr -n k8s.io snapshots rm >/dev/null 2>&1 || true
  fi
fi

echo "🛑 [4/9] Stopping and disabling kubelet and containerd services..."
sudo systemctl stop kubelet containerd >/dev/null 2>&1 || true
sudo systemctl disable kubelet containerd >/dev/null 2>&1 || true

echo "🧹 [5/9] Terminating Kubernetes-related processes..."
sudo pkill -f "kube|containerd|etcd" >/dev/null 2>&1 || true

echo "🧼 [6/9] Clearing iptables rules and network interfaces..."
sudo iptables -F >/dev/null 2>&1 || true
sudo iptables -X >/dev/null 2>&1 || true
sudo ip link delete cni0 >/dev/null 2>&1 || true
sudo ip link delete flannel.1 >/dev/null 2>&1 || true

echo "🧼 [7/9] Removing Kubernetes and containerd config/state directories..."
sudo rm -rf \
  /etc/kubernetes \
  /etc/cni/net.d \
  /etc/containerd \
  /var/lib/etcd \
  /var/lib/cni \
  /var/lib/kubelet \
  /var/lib/containerd \
  /var/run/kubernetes \
  /run/containerd \
  2>/dev/null || true

sudo find /etc /var /run /opt -type d -name '*kube*' -exec rm -rf {} + >/dev/null 2>&1 || true
sudo find /etc /var /run /opt -type d -name '*containerd*' -exec rm -rf {} + >/dev/null 2>&1 || true

echo "🧻 [8/9] Removing kubeconfig files..."
rm -rf "$HOME/.kube" /root/.kube >/dev/null 2>&1 || true

echo "📦 [9/9] Removing Kubernetes and containerd packages..."
sudo apt-mark unhold kubelet kubeadm kubectl containerd >/dev/null 2>&1 || true
sudo apt-get purge -y kubelet kubeadm kubectl containerd --allow-change-held-packages >/dev/null 2>&1 || true
sudo apt-get autoremove -y --purge >/dev/null 2>&1 || true

echo "✅ Node cleanup finished."
