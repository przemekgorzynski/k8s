#  HorizontalPodAutoscaler

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: php-apache
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: php-apache
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
behavior:
  scaleUp:
    stabilizationWindowSeconds: 0
    policies:
    - type: Percent
      value: 50
      periodSeconds: 30
    - type: Pods
      value: 4
      periodSeconds: 15
  scaleDown:
    stabilizationWindowSeconds: 300
    policies:
    - type: Percent
      value: 50
      periodSeconds: 15
  selectPolicy: Max
```


# Scaling Behavior:

- Scale-Up
    - No delay (stabilizationWindowSeconds: 0) → Pods scale immediately when needed.
    - Rules:
        - +50% pods every 30s
        - +4 pods every 15s
        - Uses the most aggressive rule (selectPolicy: Max) → It selects the policy that results in the most pods.

- Scale-Down
    - Waits 5 minutes (stabilizationWindowSeconds: 300) before reducing pods to prevent rapid fluctuations.
    - Removes 50% of pods every 15s → Ensures controlled scaling down.