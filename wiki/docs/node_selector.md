- spiecify node to run on

```yml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  nodeSelector:
    size: Large # Labels on ndoes
  containers:
  - name: nginx
    image: nginx
```