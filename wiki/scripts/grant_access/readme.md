# Kubernetes User Certificate & RBAC Setup

This project provides automation scripts to create Kubernetes user credentials using certificates and set up RBAC permissions for limited access in the default namespace.

## What It Does

- Generates a private key and CSR for a user
- Submits the CSR to Kubernetes and approves it
- Retrieves the signed certificate
- Builds a working kubeconfig file for the user
- Grants permissions to list basic resources (pods, services, configmaps, secrets) in the default namespace
- Verifies access using the generated kubeconfig

## Files

- **input.txt**  
  Configuration file. You must edit this before running the script. Define:
  - `k8s_username` – the username to create
  - `k8s_group` – the user group (used in the kubeconfig)

- **create_user_and_kubeconfig.sh**  
  Main script to generate the key, CSR, certificate, kubeconfig, and test user access.

- **grant_default_namespace_access.sh**  
  Applies a namespace-scoped `Role` and `RoleBinding` to allow the user to list core resources.

- **rbac/role.yaml**  
  Defines a `Role` that grants `get` and `list` access to pods, services, configmaps, and secrets in the `default` namespace.

- **rbac/rolebinding.yaml.template**  
  A RoleBinding template that uses `{{USERNAME}}` as a placeholder. The script fills this in based on `input.txt`.

## Setup

1. Update `input.txt` with the desired username and group.
2. Run `create_user_and_kubeconfig.sh`.
3. The script will call the RBAC script and test access automatically.



## Cli commands

1. Set Variables
```bash
export k8s_username=batman
export k8s_group="Cluster-superheroes"
export k8s_namespace=test
export work_dir="k8s-csr-${k8s_username}"
export kubeconfig_file="${k8s_username}-${k8s_group}.config"
```

2. Generate Private Key & CSR
```bash
mkdir -p "${work_dir}" && cd "${work_dir}"

openssl genrsa -out "${k8s_username}.key" 4096

openssl req -new -key "${k8s_username}.key" \
  -out "${k8s_username}.csr" \
  -subj "/CN=${k8s_username}/O=${k8s_group}" -sha256

```

3. Create Kubernetes CSR
```bash
# Encode CSR to base64
CSR_BASE64=$(base64 < "${k8s_username}.csr" | tr -d '\n')

# Write CSR manifest to file
cat <<EOF > "${k8s_username}-csr-request.yaml"
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: ${k8s_username}
spec:
  request: ${CSR_BASE64}
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF

# Apply CSR manifest
kubectl apply -f "${k8s_username}-csr-request.yaml"

```

4. Approve CSR and Get Certificate
```bash
kubectl certificate approve "${k8s_username}"

kubectl get csr "${k8s_username}" -o jsonpath='{.status.certificate}' | base64 --decode > "${k8s_username}.crt"
```

5. Extract Cluster Info
```bash
export current_context=$(kubectl config current-context)
export cluster_name=$(kubectl config view -o jsonpath="{.contexts[?(@.name==\"${current_context}\")].context.cluster}")
export server=$(kubectl config view --raw -o jsonpath="{.clusters[?(@.name==\"${cluster_name}\")].cluster.server}")
export ca_data=$(kubectl config view --raw -o jsonpath="{.clusters[?(@.name==\"${cluster_name}\")].cluster.certificate-authority-data}")
echo "${ca_data}" | base64 --decode > ca.crt
```

6. Create Kubeconfig
```bash
kubectl config --kubeconfig="${kubeconfig_file}" set-cluster "${cluster_name}" \
  --server="${server}" \
  --certificate-authority=ca.crt \
  --embed-certs=true

kubectl config --kubeconfig="${kubeconfig_file}" set-credentials "${k8s_username}" \
  --client-certificate="${k8s_username}.crt" \
  --client-key="${k8s_username}.key" \
  --embed-certs=true

kubectl config --kubeconfig="${kubeconfig_file}" set-context "${k8s_username}-context" \
  --cluster="${cluster_name}" \
  --user="${k8s_username}"

kubectl config --kubeconfig="${kubeconfig_file}" use-context "${k8s_username}-context"

```

7. Create Namespace Role and RoleBinding
```bash
kubectl create role list-resources \
  --verb=get,list \
  --resource=pods,services,configmaps,secrets \
  -n "${k8s_namespace}"

kubectl create rolebinding "${k8s_username}-access" \
  --role=list-resources \
  --user="${k8s_username}" \
  -n "${k8s_namespace}"
```

8. Test Kubeconfig
```bash
kubectl --kubeconfig="${kubeconfig_file}" get pods -n "${k8s_namespace}"
```

9. Cleanup (Optional)
```bash
kubectl delete csr "${k8s_username}"
kubectl delete rolebinding "${k8s_username}-access" -n "${k8s_namespace}"
kubectl delete role list-resources -n "${k8s_namespace}"
cd ..
rm -rf "${work_dir}"

```