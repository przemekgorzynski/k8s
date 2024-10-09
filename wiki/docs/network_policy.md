```yml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: test-network-policy
  namespace: default
spec:
  podSelector:
    matchLabels:
      role: db
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - ipBlock:              # for example traffic from external IPs outside K8s
        cidr: 172.17.0.0/16
        except:
        - 172.17.1.0/24
    - namespaceSelector:    # To allow traffic from specific namespace
        matchLabels:
          project: myproject
    - podSelector:          # Allow traffic form pods with this labels
        matchLabels:
          role: frontend
      namespaceSelector:    # If namespace and pod selector are set as one rule is threaten as AND
        matchLabels:
          project: myproject
    ports:
    - protocol: TCP
      port: 6379
  egress:
  - to:
    - ipBlock:
        cidr: 10.0.0.0/24
    - ...
    - ...
    ports:
    - protocol: TCP
      port: 5978
```