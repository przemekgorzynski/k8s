# static pod

1. Put definition in `/etc/kubernetes/manifests`
2. Find kubelet config

```
ps aux | grep -i kubelet
```

```
/usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --config=/var/lib/kubelet/config.yaml -i kubelet
```

3. Update kubelet config file configured in service properties `/var/lib/kubelet/config.yaml`

```
staticPodPath: /etc/kubernetes/manifests
```