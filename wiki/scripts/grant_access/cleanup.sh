#!/bin/bash

# Load variables
if [[ -f ./input.txt ]]; then
  source ./input.txt
else
  echo "❌ input.txt not found."
  exit 1
fi

# Validate required input
if [[ -z "$k8s_username" || -z "$k8s_group" || -z "$k8s_namespace" ]]; then
  echo "❌ 'k8s_username', 'k8s_group', or 'k8s_namespace' missing in input.txt"
  exit 1
fi

echo "🧹 Cleaning up resources for user '${k8s_username}'..."

# Delete CSR
kubectl delete csr "${k8s_username}" --ignore-not-found

# Delete RoleBinding
kubectl delete rolebinding "${k8s_username}-access" -n "${k8s_namespace}" --ignore-not-found

# Delete Role (optional — only if it's not reused)
kubectl delete role list-resources -n "${k8s_namespace}" --ignore-not-found

# Delete generated files and working directory
rm -rf "k8s-csr-${k8s_username}"

# Delete generated YAMLs (if created from templates)
rm -f rbac/role.yaml rbac/rolebinding.yaml

echo "✅ Cleanup complete for user '${k8s_username}' in namespace '${k8s_namespace}'."
