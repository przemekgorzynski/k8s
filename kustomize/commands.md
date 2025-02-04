# Install kustomize

```bash
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
```

# Build Kustomize
Does not apply reources on cluster - just transform/kustomize and print output.

```bash
kustomize build kustomize/
```

# Apply Kustomize
Apply kustomization

```bash
kustomize build kustomize/ | kubectl apply -f -
```

# Delete Kustomize
Apply kustomization

```bash
kustomize build kustomize/ | kubectl delete -f -
```