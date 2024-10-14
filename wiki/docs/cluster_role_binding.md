- `Cluster Role and ClusterRoleBindings are on namespace scope`

## Specify cluster role `cluster-superhero` and cluster group `Cluster-superheoes`

```bash
export k8s_username=batman
export k8s_cluster_role=cluster-superhero
export k8s_group=Cluster-superheoes
```

## Create cluster role and clusterrolebinding

```bash
kubectl create clusterrole ${k8s_cluster_role} --verb='*' --resource='*' # admin role
kubectl create clusterrole cluster-watcher --verb=list,get,watch --resource='*' # read only all resources
kubectl create clusterrole cluster-watcher --verb=list,get,watch --resource='nodes' # read only nodes objects

kubectl create clusterrolebinding ${k8s_cluster_role}-role-binding --clusterrole=${k8s_cluster_role} --group=${k8s_group}
```

```yml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  creationTimestamp: null
  name: cluster-watcher
rules:
- apiGroups:
  - ""
  resources:
  - '*'
  verbs:
  - list
  - get.watch

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  creationTimestamp: null
  name: cluster-superhero-role-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-superhero
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: Cluster-superheoes
```


Check permissions

```bash
kubectl auth can-i '*' '*' --as-group="${k8s_group}" --as="${k8s_user}