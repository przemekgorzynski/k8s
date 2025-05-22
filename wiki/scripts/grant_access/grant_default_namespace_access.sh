#!/bin/bash

# Load variables from input.txt
if [[ -f ./input.txt ]]; then
  source ./input.txt
else
  echo "❌ input.txt not found."
  exit 1
fi

if [[ -z "$k8s_username" ]]; then
  echo "❌ 'k8s_username' is not set in input.txt"
  exit 1
fi

# Apply the Role (static)
kubectl apply -f rbac/role.yaml

# Create a temporary rolebinding YAML with the username inserted
sed "s/{{USERNAME}}/${k8s_username}/g" rbac/rolebinding.yaml.template > rbac/rolebinding.yaml

# Apply the updated RoleBinding
kubectl apply -f rbac/rolebinding.yaml

echo "✅ Permissions granted for user '${k8s_username}' in the 'default' namespace."
