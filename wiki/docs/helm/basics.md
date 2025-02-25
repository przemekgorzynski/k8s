# Helm commands

1. Add repo

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
```

1. Download chart with proper version to directory

```bash
helm pull argo/argo-cd --version 7.7.0 --untar --destination /path/to/directory
```


2. Install argo without installing CRDs

```bash
helm install argo-cd argo/argo-cd --namespace argo-cd --create-namespace --set crds.install=false
```