- it resctrict nodes from accepting certains pods
- taint applies to node, tolertations to pod
- no toleration by default by pods, if node is tained, but pods does not set toleration no pods will be scheduled on it


## TAINT_EFFECTS:
- NoSchedule
- PreferNoSchedule
- NoExecute - also existing pod will be evicted if no not tolerate taint


## Tainting node

```
kubectl taint nodes << NODE_NAME >> key=value:<< TAINT_EFFECT >>

kubectl taint nodes node1 app=blue:NoSchedule

# Remove from node1 taint with key 'app' and effect 'NoSchedule' if one exists
kubectl taint nodes node1 app:NoSchedule-
```

## Setting Pod tolerations:

```yml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp:
  labels:
    run: my-pod
  name: my-pod
spec:
  tolerations:
  - key: "app"
    operator: "Equal"
    value: "blue"
    effect: "NoSchedule"
  containers:
    image: nginx
    name: pod
```