- Run pod

    `kubectl run nginx --image=nginx`

- Generate POD Manifest YAML file (-o yaml). Don't create it(--dry-run)
    
    `kubectl run nginx --image=nginx --dry-run=client -o yaml`

- Create a deployment

    `kubectl create deployment --image=nginx nginx`

- Generate Deployment with 4 Replicas
    `kubectl create deployment nginx --image=nginx --replicas=4`

- Scale deployment

    `kubectl scale deployment nginx --replicas=4`

- Create a Service named redis-service of type ClusterIP to expose pod redis on port 6379

    `kubectl expose pod redis --port=6379 --name redis-service`

- Create secret

    `kubectl create secret generic secret_name --from-literal=key=value`