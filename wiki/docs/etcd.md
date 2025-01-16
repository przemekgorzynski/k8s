1. Snapshot
```
export ETCDCTL_API=3
etcdctl snapshot save /opt/snapshot-pre-boot.db \
--endpoints=https://127.0.0.1:2379 \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key
```

```
ETCDCTL_API=3 etcdctl snapshot status /opt/snapshot-pre-boot.db
```

2. Restore
```
ETCDCTL_API=3 etcdctl snapshot restore /opt/snapshot-pre-boot.db --data-dir /var/lib/etcd-from-backup
```

3. Configure etcd.service by updating etcd data volume and --data-dir property

```yml
- hostPath:
    path: /var/lib/etcd-from-backup
    type: DirectoryOrCreate
  name: etcd-data
...
--data-dir=/var/lib/etcd-from-backup
```
