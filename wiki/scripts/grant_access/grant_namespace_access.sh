#!/bin/bash

# Load input
source ./input.txt

# Validate inputs
if [[ -z "$k8s_username" || -z "$k8s_namespace" ]]; then
  echo "❌ 'k8s_username' or 'k8s_namespace' not set in input.txt"
  exit 1
fi

# Generate namespaced Role YAML
sed "s/{{NAMESPACE}}/${k8s_namespace}/g" rbac/role.yaml.template > rbac/role.yaml

# Apply Role
kubectl apply -f rbac/role.yaml

# Generate RoleBinding from template
sed "s/{{USERNAME}}/${k8s_username}/g; s/{{NAMESPACE}}/${k8s_namespace}/g" \
  rbac/rolebinding.yaml.template > rbac/rolebinding.yaml

# Apply RoleBinding
kubectl apply -f rbac/rolebinding.yaml

echo "✅ '${k8s_username}' granted access in namespace '${k8s_namespace}'."
