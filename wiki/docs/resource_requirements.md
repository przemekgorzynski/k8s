- set resource requests
```YAML
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: nginx
    image: nginx:1.14.2
    resource:
        requests:
            memory: "1Gi"
            cpu: 1
        limits:
            memory: "2Gi"
            cpu: 2
```

```bash
1Gi = 1024
1G  = 1000
1 cpu = 1 AWC vCPU / 1 Azure CPU ...
```

- can set default limit range if not provided in pod definition

```yml
apiVersion: v1
kind: LimitRange
metadata:
  name: cpu-resource-constraint
spec:
  limits:
  - default: # this section defines default limits
      cpu: 500m
    defaultRequest: # this section defines default requests
      cpu: 500m
    max: # max and min define the limit range
      cpu: "1"
    min:
      cpu: 100m
    type: Container
```

```yml
apiVersion: v1
kind: LimitRange
metadata:
  name: memory-resource-constraint
spec:
  limits:
  - default: # this section defines default limits
      memory: 1Gi
    defaultRequest: # this section defines default requests
      memory: 1Gi
    max: # max and min define the limit range
      memory: 1Gi
    min:
      memory: 100m
    type: Container
```

- to definfe global limits all pods can consume within namespace use resource quata

```yml
- apiVersion: v1
  kind: ResourceQuota
  metadata:
    name: pods-medium
  spec:
    hard:
      requests.cpu: 4
      requests.memory: 4Gi
      limit.cpu: 10         # All together consumption
      limit.memory: 20Gi
      
```