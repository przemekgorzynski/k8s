# Install kustomize

```bash
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
```

# Build Kustomize
Does not apply reources on cluster - just transform/kustomize and print output.

```bash
kustomize build workload/
```

# Apply Kustomize
Apply kustomization

```bash
kustomize build workload/ | kubectl apply -f -
```

```bash
kustomize build workload/ --enable-helm | kubectl apply -f -
```

# Delete Kustomize
Apply kustomization

```bash
kustomize build workload/ | kubectl delete -f -
```