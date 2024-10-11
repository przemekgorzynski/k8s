
- [Kubectl](#kubectl)
- [Pods](#pods)
- [Deployments](#deployments)
- [Services](#services)
- [Secrets](#secrets)
- [Rollouts](#rollouts)

## KUBECTL
- Switch to namespace

    ```bash
    kubectl config set-context --current --namespace=ingress-nginx
    ```

- Check permissions

    ```bash
    kubectl auth can-i delete nodes
    ```

- Check permissions as different user

    ```bash
    kubectl auth can-i delete nodes --as dev-user
    ```

## PODS
- Run pod

    ```bash
    kubectl run nginx --image=nginx
    ```

- generate YAML for pod with a lot on config upfront

    ```bash
    kubectl run nginx --image=nginx --restart=Never --port=80 --namespace=myname --command --env=HOSTNAME=local --labels=bu=finance,env=dev --dry-run -o yaml -- /bin/sh -c 'echo hello world'
    ```
    ```yml
    apiVersion: v1
    kind: Pod
    metadata:
      creationTimestamp: null
      labels:
        bu: finance
        env: dev
      name: nginx
      namespace: myname
    spec:
      containers:
      - command:
        - /bin/sh
        - -c
        - echo hello world
        env:
        - name: HOSTNAME
          value: local
        image: nginx
        name: nginx
        ports:
        - containerPort: 80
        resources: {}
      dnsPolicy: ClusterFirst
      restartPolicy: Never
    status: {}
    ```

- Generate POD Manifest YAML file (-o yaml). Don't create it(--dry-run)
    
    ```bash
    kubectl run nginx --image=nginx --dry-run=client -o yaml
    ```

## DEPLOYMENTS

- Create a deployment

    ```bash
    kubectl create deployment --image=nginx nginx (--record) # add record flag to see change-cause in deployment rollout history
    ```

- Generate Deployment with 4 Replicas
    ```bash
    kubectl create deployment nginx --image=nginx --replicas=4
    ```

- Scale deployment

    ```bash
    kubectl scale deployment nginx --replicas=4
    ```

-  Update image from CLI

    ```bash
    kubectl set image << DEPLOYMENT_NAME >> << container_NAME>> << NEW_IMAGE >>
    kubectl set image deployment/frontend simple-webapp=kodekloud/webapp-color:v2
    ```

## SERVICES
- Create a Service named redis-service of type ClusterIP to expose pod redis on port 6379

    ```bash
    kubectl expose pod redis --port=6379 --name redis-service
    ```

## SECRETS
- Create secret

    ```bash
    kubectl create secret generic secret_name --from-literal=key=value
    ```



## ROLLOUTS
- Show deployment rollout

    ```bash
     kubectl rollout status deployment << DEPLOYMENT_NAME >>
     kubectl rollout history deployment << DEPLOYMENT_NAME >> (--revision=1 )# optional revision for individual
     ```

- Rollback deployment

    ```bash
    rollou undo << DEPLOYMENT_NAME >>
    rollou undo << DEPLOYMENT_NAME >> --revision=XX
    ```

- Add change-cause with --record flag

    ```bash
        kubectl rollout history deployment nginx
        deployment.extensions/nginx
        REVISION CHANGE-CAUSE
        1     <none>
    ```

    ```bash
        kubectl set image deployment nginx nginx=nginx:1.17 --record

        kubectl rollout history deployment nginx deployment.extensions/nginx
        REVISION CHANGE-CAUSE
        1     <none>
        2     kubectl set image deployment nginx nginx=nginx:1.17 --record=true
    ```