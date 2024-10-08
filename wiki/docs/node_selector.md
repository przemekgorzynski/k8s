- spiecify node to run on
- cannot provide advances expressions line `NOT, OR`

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