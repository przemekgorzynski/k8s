## patch namespace

```bash
kubectl patch namespace monitoring -p '{"spec":{"finalizers":[]}}' --type=merge
```