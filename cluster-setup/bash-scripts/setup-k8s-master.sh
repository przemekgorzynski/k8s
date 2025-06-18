#!/bin/bash
set -euo pipefail

# 🔧 Configurable Variables
K8S_VERSION="v1.31.0"
K8S_MINOR="${K8S_VERSION%.*}"  # Extracts "v1.31"
CONFIG_FILE="$(dirname "$0")/kubeadm-config.yml"
USER_HOME=$(eval echo ~"${SUDO_USER:-$USER}")
MASTER_HOSTNAME="k8s-master"
TAINT_MASTER=true
AUTO_REBOOT=false

#################################################################
echo "🧪 Checking if Kubernetes cluster is already running..."
if kubectl --kubeconfig="/etc/kubernetes/admin.conf" get nodes &>/dev/null; then
  echo "⚠️ Cluster is already running. Run cleanup first."
  echo -e "\n🧹  To clean up the existing cluster, run:\n➡️   ./run-remote.sh cleanup\n"
  echo -e "\n🧹  To reset and redeploy the cluster, run:\n➡️   ./run-remote.sh redeploy\n"
  exit 0
fi

#################################################################
echo "🖥️ [1/11] Setting hostname to: $MASTER_HOSTNAME"
sudo hostnamectl set-hostname "$MASTER_HOSTNAME"

#################################################################
echo "🔧 [2/11] Disabling swap..."
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

#################################################################
echo "📶 [3/11] Configuring sysctl parameters..."
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
EOF
sudo modprobe br_netfilter
sudo sysctl --system

#################################################################
echo "📦 [4/11] Installing containerd..."
sudo apt-get update
sudo apt-get install -y containerd

#################################################################
echo "⚙️ [5/11] Configuring containerd with systemd as cgroup driver..."
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

#################################################################
echo "⬇️ [6/11] Installing kubelet, kubeadm, kubectl (${K8S_VERSION})..."
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL "https://pkgs.k8s.io/core:/stable:/${K8S_MINOR}/deb/Release.key" | \
  gpg --dearmor --batch --yes | \
  sudo tee /etc/apt/keyrings/kubernetes-apt-keyring.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${K8S_MINOR}/deb/ /" | \
  sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now kubelet

#################################################################
echo "📄 [7/11] Checking kubeadm config file..."
if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ kubeadm config file not found: $CONFIG_FILE"
  exit 1
fi

#################################################################
echo "🚀 [8/11] Initializing the Kubernetes cluster with kubeadm..."
sudo kubeadm init --config="$CONFIG_FILE"

#################################################################
echo "🔐 [9/11] Setting up kubectl config for current user..."
mkdir -p "$USER_HOME/.kube"
sudo cp -f /etc/kubernetes/admin.conf "$USER_HOME/.kube/config"
sudo chown "$(id -u ${SUDO_USER:-$USER}):$(id -g ${SUDO_USER:-$USER})" "$USER_HOME/.kube/config"
echo "📎 Adding KUBECONFIG to .bashrc for user: ${SUDO_USER:-$USER}"
echo 'export KUBECONFIG=$HOME/.kube/config' | sudo tee -a "$USER_HOME/.bashrc" > /dev/null

#################################################################
echo "🌐 [10/11] Installing Flannel CNI..."
kubectl --kubeconfig="$USER_HOME/.kube/config" apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

#################################################################
if [[ "$TAINT_MASTER" == "true" ]]; then
  echo "🧹 [11/11] Removing control-plane taint so workloads can be scheduled on the master node..."
  NODE_NAME=$(kubectl --kubeconfig="$USER_HOME/.kube/config" get nodes -o jsonpath='{.items[0].metadata.name}')
  kubectl --kubeconfig="$USER_HOME/.kube/config" taint nodes "$NODE_NAME" node-role.kubernetes.io/control-plane:NoSchedule- || true
fi

#################################################################
echo "✅ Kubernetes master setup complete!"

#################################################################
if [[ "$AUTO_REBOOT" == "true" ]]; then
  echo -e "\n🔄 Rebooting the system to finalize setup..."
  sudo reboot
fi