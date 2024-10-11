- Read only role to pods resources, and binding to ServiceAccount. `Role and RoleBindings are on namespace scope`

```bash
kubectl create role pod-reader \
  --namespace=default \
  --verb=get --verb=watch --verb=list \
  --resource=pods
```

```bash
kubectl create rolebinding read-pods \
  --namespace=default \
  --role=pod-reader \
  --serviceaccount=default:dashboard-sa
```

```yml
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups:
  - ''
  resources:
  - pods
  verbs:
  - get
  - watch
  - list
  resourceNames: # If we want to limit access eg. to 1 pod
  - blue
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: read-pods
  namespace: default
subjects:
- kind: ServiceAccount
  name: dashboard-sa # Name is case sensitive
  namespace: default
roleRef:
  kind: Role #this must be Role or ClusterRole
  name: pod-reader # this must match the name of the Role or ClusterRole you wish to bind to
  apiGroup: rbac.authorization.k8s.io
```