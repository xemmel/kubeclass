
### Port-forward (Expose service on client machine)

```powershell

kubectl port-forward service/simple-service 4000:80

```

### Exec (Bash into pod)

```powershell

kubectl exec -it secondpod4 -- bash

```

### Log (Log Application log in Pod/Container)

```powershell

kubectl logs -l app=app1 -f

```

### Create Namespace

```powershell

kubectl create namespace mongo

```

### View Context

```powershell

kubectl config get-contexts

```

### Change default namespace 

```powershell

kubectl config set-context --current --namespace mongo

```


### Disable Schedule (new pods)

```powershell

kubectl cordon multinodes-worker

```


### Drain pods from node

```powershell

kubectl drain --ignore-daemonsets --force multinodes-worker

```

### Enable Schedule

```powershell

kubectl uncordon multinodes-worker

```

### Restart all pods

```powershell

kubectl rollout restart deployment.apps/simple-deployment

```


### Helm

Path: Templates

```powershell

helm install appxtest .\Helm\ --values .\Helm\values-prod.yaml --namespace appxprod --create-namespace


curl localhost/testapplication1

```