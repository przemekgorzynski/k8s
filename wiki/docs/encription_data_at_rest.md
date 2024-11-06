# Encrypts data stored in ETCD
#### https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/

- Check if encryption provider is configred

```bash
ps aux | grep kube-api
```

In output flag `--encryption-provider-config` should be set. Otherwise it is not configured.

- Prepare encryption key used for encryption

```bash
KEY_FOR_ENCRYPTION = $(head -c 32 /dev/urandom | base64)
```

- Create `EncryptionConfiguration` YAML config and store in `/etc/kubernetes/enc`
```YAML
---
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${KEY_FOR_ENCRYPTION}
      - identity: {}
```

- Modify Kubernetes API config to use prepared config`/etc/kubernetes/manifests/kube-apiserver.yaml`

```bash
vim /etc/kubernetes/manifests/kube-apiserver.yaml
```

And add following config
```YAML
spec:
  containers:
  - command:
    - kube-apiserver
    ...
    - --encryption-provider-config=/etc/kubernetes/enc/enc.yaml  # add this line
    volumeMounts:
    ...
    - name: enc                           # add this line
      mountPath: /etc/kubernetes/enc      # add this line
      readOnly: true                      # add this line
    ...
  volumes:
  ...
  - name: enc                             # add this line
    hostPath:                             # add this line
      path: /etc/kubernetes/enc           # add this line
      type: DirectoryOrCreate             # add this line
  ...
```

- Wait for API to restart

```bash
ctr c ls
```

- Encrypt all secrets created before `EncryptionConfiguration` applied

```bash
kubectl get secrets --all-namespaces -o json | kubectl replace -f -
```
