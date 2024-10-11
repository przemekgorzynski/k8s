
- [General](#general)
- [Validating and Mutating](#validating-and-mutating)

# General

Helps to enforce additional checks and cluster behavious - eg `NamespaceLifecycle` `DefaultStorageClass`

`kubectl -> Authentocation -> Authorization -> Admission Controllers -> ...`

- check enabled admission controlles

    ```baash
    kube-apiserver -h | grep enable-admission-plugins
    kubectl exec -it kube-apiserver-controlplane -n kube-system -- kube-apiserver -h
    ps -ef | grep kube-apiserver | grep enable-admission-plugins
    ```

- can be configured in `/etc/kubernetes/mainfests/api-server.yaml` or by cli

    ```bash
    kube-apiserver --enable-admission-plugins=NamespaceLifecycle,LimitRanger ...
    kube-apiserver --disable-admission-plugins=PodNodeSelector,AlwaysDeny ...
    ```

    ```yml
    # Add flags to etc/kubernetes/mainfests/kube-apiserver.yaml
    --enable-admission-plugins=NamespaceLifecycle,LimitRanger
    --disable-admission-plugins=PodNodeSelector,AlwaysDeny
    ```



# Validating and Mutating
`Mutating` - goes first, change object before it's created - eg. add storage class if not specified by `DefaultStorageClass` admission controller

`Validating` - goes 2nd, valide - approve or deny
