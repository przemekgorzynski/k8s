

```yml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: nginx
    image: nginx
    redinessProbe:
      httpGet:
        path: /api/ready
        port: 8080
      tcpSocket:
        port: 3306
      exec:
        command:
          - cat
          - /app/is_ready
      initialDelaySeconds: 10
      periodSeconds: 5
    livenessProbe:
        httpGet:
          path: /api/ready
          port: 8080
        initialDelaySeconds: 10
        periodSeconds: 5
        tcpSocket:
          port: 3306
        exec:
          command:
            - cat
            - /app/is_ready
        initialDelaySeconds: 10
        periodSeconds: 5
```