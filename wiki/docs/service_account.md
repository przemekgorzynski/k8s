- create Service Account and Token

```bash
kubectl create serviceaccount  << SERVICE_ACCOUNT_NAME >>
```

```bash
# Expiring
kubectl create token << SERVICE_ACCOUNT_NAME >>
```

OR

```yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: << NAME >>
  namespace: << NAMESPACE >>
--- # Non-expiring
apiVersion: v1
kind: Secret
metadata:
  name: << NAME >>-token
  namespace: << NAMESPACE >>
  annotations:
    kubernetes.io/service-account.name: s<< NAME >>
type: kubernetes.io/service-account-token
```

- Mount to pod 

```YAML
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  serviceAccountName: << SERVICE_ACCOUNT_NAME >>
  containers:
  - name: nginx
    image: nginx:1.14.2
```

- service account should have assignes RoleBinding - see [RoleBinding](role_binding.md) or [ClusterRoleBinding](cluster_role_binding.md)


# You can also use `TokenRequest API` to use generated token 

https://kubernetes.io/docs/concepts/storage/projected-volumes/#serviceaccounttoken

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: sa-token-test
spec:
  containers:
  - name: container-test
    image: busybox:1.28
    command: ["sleep", "3600"]
    volumeMounts:
    - name: token-vol
      mountPath: "/service-account"
      readOnly: true
  serviceAccountName: default
  volumes:
  - name: token-vol
    projected:
      sources:
      - serviceAccountToken:
          audience: api
          expirationSeconds: 3600
          path: token
``````