# Use a lightweight base image
FROM alpine:3.18

# Install required packages: curl, wget, bash, and dependencies
RUN apk add --no-cache curl wget bash git

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install helm
RUN curl -LO https://get.helm.sh/helm-v3.13.0-linux-amd64.tar.gz \
    && tar -zxvf helm-v3.13.0-linux-amd64.tar.gz \
    && mv linux-amd64/helm /usr/local/bin/helm \
    && rm -rf helm-v3.13.0-linux-amd64.tar.gz linux-amd64

# Install Kustomize
RUN curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash

CMD ["/bin/bash"]