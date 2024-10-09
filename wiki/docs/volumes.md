- [Persistent Volume](#persistent-volume)
- [Persistent Volume Claim](#persistent-volume-claim)
- [Storage Class](#storage-class)
- [Volume usage in pod](#volume-usage-in-pod)

## Persistent Volume

```yml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv0003
  labels:
    env: dev
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  local:  # Type: [ nfs, local, awsElasticBlockStore, azureFile, azureDisk ... ]
    path: /mnt/disks/ssd1
```

Reclaim Policy:
- Retain

    Retain until manually deleted by admin. Not available for re-use.

- Delete

    Deleve volume when PVC is deleted.

- Recycle

    Policy performs a basic scrub (rm -rf /thevolume/*) on the volume and makes it available again for a new claim


Access Modes:
- ReadWriteOnce

    Volume can be mounted as read-write by a single node. ReadWriteOnce access mode still can allow multiple pods to access the volume when the pods are running on the same node.

- ReadOnlyMany

    Volume can be mounted as read-only by many nodes.

- ReadWriteMany

    Volume can be mounted as read-write by many nodes.

- ReadWriteOncePod [ Kubernetes v1.29 ]

    Volume can be mounted as read-write by a single Pod. Use ReadWriteOncePod access mode if you want to ensure that only one pod across the whole cluster can read that PVC or write to it.

## Persistent Volume Claim

```yml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: myclaim
spec:
  accessModes:
    - ReadWriteOnce
  volumeMode: Filesystem
  resources:
    requests:
      storage: 5Gi
```

## Storage Class

Storage class replaces PV for dynamic volume creation in providers like Google, Azure, AWS
```yml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: google-storage
provisioner: kubernetes.io/gce-pd
parameters: # Depends on provisioner
    type: pd-standard
    ....
```
Need to use storage class in PVC instead of pv

```yml
...
spec:
    accessModes:
        - ...
    storageClassName: google-storage
...
```
## Volume usage in pod
```yml
# hostPath volume defined in pod definition
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
    - name: myfrontend
      image: nginx
      volumeMounts:
      - mountPath: "/var/www/html"
        name: mypd
  volumes:
    - name: mypd
      hostPath:
        path: /var/log/webapp
```
```yml
# Claim usage
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
    - name: myfrontend
      image: nginx
      volumeMounts:
      - mountPath: "/var/www/html"
        name: mypd
  volumes:
    - name: mypd
      persistentVolumeClaim:
        claimName: myclaim
```