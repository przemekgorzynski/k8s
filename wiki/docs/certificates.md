# Creation of Certificate 

Example based on cluster role, if you want to limit to namespace use role and role binding

## Specify username `batman`, cluster role `cluster-superhero` and cluster group `Cluster-superheoes`

```bash
export k8s_username=batman
export k8s_group=Cluster-superheoes
```

## Generate openssl key for user

```bash
openssl genrsa -out ${k8s_username}.key 4096
```

## Generate CSR - certificate signing request

```bash
openssl req -new -key ${k8s_username}.key -out ${k8s_username}.csr -subj "/CN=${k8s_username}/0=${k8s_group}" -sha256
```

## Create env variable to capture CSR_DATA

```bash
CSR_DATA=$(base64 ${k8s_username}.csr | tr -d '\n')
```

## Create Kubernetes CAR YAML

```bash
cat <<EOF > ${k8s_username}-csr-request.yml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: ${k8s_username}
spec:
  request: ${CSR_DATA}
  signerName: kubernetes.io/kubelet-apiserver-client
  usages:
  - client auth
EOF
```

it will produce file with content

```yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: batman
spec:
  request: <<BASE64ENCODEDCSR>>
  signerName: kubernetes.io/kubelet-apiserver-client
  usages:
  - client auth
```

## Apply CSR

```
kubectl apply -f ${k8s_username}-csr-request.yml
```

## Get CSR

```bash
kubectl get csr
```

## Approve CSR and retrieve the approved certificate
```bash
kubectl certificate approve ${k8s_username}
kubectl get csr ${k8s_username} -o jsonpath='{.status.certificate}' | base64 --decode > ${k8s_username}.crt
```

## Generate kubeconfig file for new user

Make a copy of current kubeconfig and unset data

```bash
cp /root/.kube/config ${k8s_username}-${k8s_group}.config
KUBECONFIG=${k8s_username}-${k8s_group}.config kubectl config unset users.default
KUBECONFIG=${k8s_username}-${k8s_group}.config kubectl config delete-context default
KUBECONFIG=${k8s_username}-${k8s_group}.config kubectl config unset current-context
```

It will create base config file with CA and API server

```yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: <<redacted>>
    server: https://127.0.0.1:6443
  name: default
contexts: null
current-context: ""
kind: Config
preferences: {}
users: null
```

Embed user information to base kube config file

```bash
KUBECONFIG=${k8s_username}-${k8s_group}.config kubectl config set-credentials ${k8s_username} --client-certificate=${k8s_username}.crt --client-key=${k8s_username}.key --embed-certs=true
KUBECONFIG=${k8s_username}-${k8s_group}.config kubectl config set-context default --user ${k8s_username}
KUBECONFIG=${k8s_username}-${k8s_group}.config kubectl config use-context default
```