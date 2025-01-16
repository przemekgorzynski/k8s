1. Drain node
```
kubectl cordon NODE- make unschedulable
kubectl drain NODE - make unschedulable and migrate pods to another nodes
```

2. Check available kubeadm versions - add repos if necessary
```
sudo apt-cache madison kubeadm


echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb
/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/k
ubernetes-apt-keyring.gpg
```

3. Upgrade kubeadm
```
sudo apt-mark unhold kubeadm && \
sudo apt-get update && sudo apt-get install -y kubeadm='1.31.0-1.1' && \
sudo apt-mark hold kubeadm
```

4. Check kubeadm available version
```
kubeadm upgrade plan
```

5. Upgrade kubeadm

MASTER
```
kubeadm upgrade apply v1.31.4
```

WORKER
```
sudo kubeadm upgrade node
```

6. Upgrade Kubelet
```
sudo apt-mark unhold kubelet kubectl && \
sudo apt-get update && sudo apt-get install -y kubelet='1.31.0-1.1' kubectl='1.31.0-1.1' && \
sudo apt-mark hold kubelet kubectl
```

7. Restart kubelet service
```
sudo systemctl restart kubelet
```

8. Make node schedulable again
```
kubectl uncordon NODE
```