1. Check available kubeadm versions - add repos if necessary
```
sudo apt-cache madison kubeadm
```

2. Upgrade kubeadm
```
sudo apt-mark unhold kubeadm && \
sudo apt-get update && sudo apt-get install -y kubeadm='v1.31' && \
sudo apt-mark hold kubeadm
```

3. Check kubeadm available version
```
kubeadm upgrade plan
```

4. Drain node
```
kubectl cordon NODE- make unschedulable
kubectl drain NODE - make unschedulable and migrate pods to another nodes
```

5. Upgrade cluster
```
kubeadm upgrade apply v1.31.4
```

6. Upgrade Kubelet
```
sudo apt-mark unhold kubelet kubectl && \
sudo apt-get update && sudo apt-get install -y kubelet='v1.31.0' kubectl='v1.31.0' && \
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