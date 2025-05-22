#!/bin/bash

# Load variables from input.txt
if [[ -f ./input.txt ]]; then
  source ./input.txt
else
  echo "❌ input.txt not found. Please provide one with 'k8s_username' and 'k8s_group'."
  exit 1
fi

# Validate required variables
if [[ -z "$k8s_username" || -z "$k8s_group" ]]; then
  echo "❌ 'k8s_username' and/or 'k8s_group' are not defined in input.txt"
  exit 1
fi

# Derived variables
export work_dir="k8s-csr-${k8s_username}"
export KUBECONFIG_FILE="${k8s_username}-${k8s_group}.config"

# Create working directory
mkdir -p "${work_dir}"
cd "${work_dir}" || exit 1

# Step 1: Generate private key
openssl genrsa -out "${k8s_username}.key" 4096

# Step 2: Generate CSR with correct subject
openssl req -new -key "${k8s_username}.key" -out "${k8s_username}.csr" \
  -subj "/CN=${k8s_username}/O=${k8s_group}" -sha256

# Step 3: Base64 encode the CSR
CSR_DATA=$(base64 < "${k8s_username}.csr" | tr -d '\n')

# Step 4: Create CSR YAML manifest
cat <<EOF > "${k8s_username}-csr-request.yml"
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: ${k8s_username}
spec:
  request: ${CSR_DATA}
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF

# Step 5: Submit CSR
kubectl apply -f "${k8s_username}-csr-request.yml"

# Step 6: Approve CSR
kubectl certificate approve "${k8s_username}"

# Step 7: Retrieve issued certificate directly
kubectl get csr "${k8s_username}" -o jsonpath='{.status.certificate}' | base64 --decode > "${k8s_username}.crt"

sleep 5

if [[ ! -s "${k8s_username}.crt" ]]; then
  echo "❌ Certificate retrieval failed. The CSR may not be signed yet."
  exit 1
fi

echo "✅ Certificate issued and saved to ${k8s_username}.crt"

# Step 8: Generate kubeconfig
CURRENT_CONTEXT=$(kubectl config current-context)
CLUSTER_NAME=$(kubectl config view -o jsonpath="{.contexts[?(@.name==\"${CURRENT_CONTEXT}\")].context.cluster}")
CLUSTER_SERVER=$(kubectl config view --raw -o jsonpath="{.clusters[?(@.name==\"${CLUSTER_NAME}\")].cluster.server}")
CLUSTER_CA_DATA=$(kubectl config view --raw -o jsonpath="{.clusters[?(@.name==\"${CLUSTER_NAME}\")].cluster.certificate-authority-data}")

# Decode CA and save to file
echo "${CLUSTER_CA_DATA}" | base64 --decode > ca.crt

# Set cluster
kubectl config --kubeconfig="${KUBECONFIG_FILE}" set-cluster "${CLUSTER_NAME}" \
  --server="${CLUSTER_SERVER}" \
  --certificate-authority=ca.crt \
  --embed-certs=true

# Set credentials
kubectl config --kubeconfig="${KUBECONFIG_FILE}" set-credentials "${k8s_username}" \
  --client-certificate="${k8s_username}.crt" \
  --client-key="${k8s_username}.key" \
  --embed-certs=true

# Set context
kubectl config --kubeconfig="${KUBECONFIG_FILE}" set-context "${k8s_username}-context" \
  --cluster="${CLUSTER_NAME}" \
  --user="${k8s_username}"

kubectl config --kubeconfig="${KUBECONFIG_FILE}" use-context "${k8s_username}-context"

echo "✅ Final kubeconfig generated: ${work_dir}/${KUBECONFIG_FILE}"

# Step 8.5: Apply namespace-level permissions
cd .. || exit 1

if [[ -f ./grant_default_namespace_access.sh ]]; then
  ./grant_default_namespace_access.sh
else
  echo "⚠️ Permissions script 'grant_default_namespace_access.sh' not found. Skipping RBAC setup."
fi

cd "${work_dir}" || exit 1

# Step 9: Clean up intermediate files
rm -f "${k8s_username}.csr" ca.crt
echo "🧹 Cleaned up intermediate files (.csr, ca.crt)"

# Step 10: Test kubeconfig
echo "🔍 Testing access with the new kubeconfig..."

kubectl --kubeconfig="${KUBECONFIG_FILE}" get pods -n default &> test_output.txt
if [[ $? -eq 0 ]]; then
  echo "✅ Kubeconfig works. '${k8s_username}' can list pods in the 'default' namespace."
else
  echo "❌ Kubeconfig test failed. Access denied or configuration is broken."
  cat test_output.txt
fi
