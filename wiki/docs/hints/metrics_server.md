# Kubernetes Metrics Stack: Metrics Server + Kube-State-Metrics

This repository provides a quick setup script to install the following components:

- **Metrics Server** – used for Kubernetes Horizontal Pod Autoscaler (HPA) and `kubectl top`
- **kube-state-metrics** – used by Prometheus to monitor Kubernetes object states (pods, deployments, PVCs, etc.)

> ⚠️ Note: Metrics Server is **not** compatible with Prometheus and should only be used for autoscaling and basic metrics via `kubectl`.

---

## 🔧 What the Script Does

- Installs a specific version of `metrics-server`
- Applies necessary patches for insecure Kubelet TLS (useful on self-managed clusters)
- Installs `kube-state-metrics` for Prometheus-compatible metrics
- Prints follow-up usage commands

---

## 📦 Requirements

- Kubernetes cluster
- `kubectl` access with cluster-admin privileges
- Internet access to pull official manifests


## 🚀 How to Run

The install script is located here:  
[📂 wiki/scripts/install-metrics-server/install-metrics.sh](wiki/scripts/install-metrics-server/install-metrics.sh)
