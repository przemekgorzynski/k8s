- advances capabilities to place pod on node

## Node Affinity options
- requiredDuringSchedulingIgnoredDuringExecution
- preferredDuringSchedulingIgnoredDuringExecution


## Adding Affinity to pods
Node should be labeled first

```yml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: size
            operator: In / NotIn / Exists
            values:
            - Large
            - Medium
  containers:
  - name: nginx
    image: nginx
```

```yml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
          - matchExpressions:
            - key: node-role.kubernetes.io/control-plane
              operator: Exists
  containers:
  - name: nginx
    image: nginx
```