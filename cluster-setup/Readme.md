# 🚀 Kubernetes Cluster Setup & Cleanup Scripts

This repository contains helper scripts for initializing or resetting a Kubernetes single-node cluster using `kubeadm`, `containerd`, and Flannel CNI. Supports both **local and remote execution**.

---

## 🧼 Cluster Cleanup

Use this to fully reset and remove an existing Kubernetes installation from a node.

### 🔧 Run on remote host:

```bash
./bash-scripts/run-remote.sh cleanup
```

> This resets kubeadm, removes Kubernetes-related files, packages, and optionally containerd.

---

## 📆 Install Kubernetes Master Node

You can run the setup **remotely** or **locally**, depending on your scenario.

### 🌐 Remote installation

```bash
./bash-scripts/run-remote-setup.sh deploy
```

This script:

- Uploads `setup-k8s-master.sh` and `kubeadm-config.yml` to the remote host
- Executes them with `sudo`
- Initializes the Kubernetes master node on that machine

### 🖥️ Local installation

```bash
sudo ./bash-scripts/setup-k8s-master.sh
```

Make sure `kubeadm-config.yml` is in the **same directory** as the script.

---

## 📁 Files

| File                  | Description                               |
| --------------------- | ----------------------------------------- |
| `setup-k8s-master.sh` | Main script to install Kubernetes master  |
| `kubeadm-config.yml`  | Cluster configuration for `kubeadm init`  |
| `cleanup-cluster.sh`  | Full Kubernetes reset/cleanup script      |
| `run-remote-setup.sh` | Wrapper script for remote setup execution |

---

## ✅ After Installation

Once the setup completes, log in and run:

```bash
kubectl get nodes
kubectl get pods -n kube-system
```

The script will also guide you on how to generate the **join command** for worker nodes.

---
