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

