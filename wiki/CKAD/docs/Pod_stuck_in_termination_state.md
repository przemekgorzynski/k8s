- Get the namespace resource in JSON format.

```bash
kubectl get namespace <NAMESPACE> -o json > namespace.json
```

- Edit the finalizers field.

```json
"spec": {
    "finalizers": [
        "kubernetes"
    ]
}
```
to
```json
"spec": {
    "finalizers": []
}
```

- Apply the changes to remove the finalizers

```bash
kubectl replace --raw "/api/v1/namespaces/<NAMESPACE>/finalize" -f namespace.json
```