Use pod affinity to co-locate pods.
value `topologyKey: kubernetes.io/hostname` is also a node label.


1. Pod Affinity - put pod on the same host where are running pods labeled with `app=nginx`

```yml
podAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchExpressions:
      - key: app
        operator: In
        values:
        - nginx
    topologyKey: kubernetes.io/hostname
```

2. Pod Anti Affinity - DO NOT put pod on the same host where are running pods labeled with `app=nginx`
If number of pods > number od nodes some of them will be in pending state

```yml
podAntiAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchExpressions:
      - key: app
        operator: In
        values:
        - nginx
    topologyKey: kubernetes.io/hostname
```
      
3. Example

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: kubernetes.io/os
                operator: In
                values:
                - linux
              - key: kubernetes.io/hostname
                operator: In
                values:
                - k8s-master
                - k8s-node01
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 1
            preference:
              matchExpressions:
              - key: kubernetes.io/hostname
                operator: In
                values:
                - k8s-master
          - weight: 2 # higher - more important
            preference:
              matchExpressions:
              - key: kubernetes.io/hostname
                operator: In
                values:
                - k8s-node01
        podAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - db
            topologyKey: kubernetes.io/hostname
      containers:
        - name: nginx
          image: nginx:latest
          ports:
            - containerPort: 80
          resources:
            requests:
              cpu: "100m"  # HPA NEEDS THIS!
            limits:
              cpu: "200m"
```