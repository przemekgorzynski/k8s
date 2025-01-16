
dns config on each pod

`k exec -it test -- cat /etc/resolv.conf`


reaching services between namespaces

`mysql.payroll.svc.cluster.local`


NSLOOKUP service
```bash
k exec hr -- nslookup mysql.payroll.svc.cluster.local
Server:         172.20.0.10
Address:        172.20.0.10#53

Name:   mysql.payroll.svc.cluster.local
Address: 172.20.64.147
```

NSLOOKUP pod
```bash
k exec hr -- nslookup 172-17-0-4.default.pod.cluster.local
Server:         172.20.0.10
Address:        172.20.0.10#53

Name:   172-17-0-4.default.pod.cluster.local
Address: 172.17.0.4
```