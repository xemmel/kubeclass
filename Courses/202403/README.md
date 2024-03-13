## Kubernetes 2024 March


### Exec into pod

```powershell

kubectl exec -it ubuntu -- bash

```


### List pods IP etc.

```powershell

kubectl get pods -o wide

```

### Describe a service 

```powershell

kubectl describe service hello-service

```


### Create/Set namespace

```powershell

$namespace = "mongo"

### Create namespace
kubectl create namespace $namespace


### Change namespace context in kubectl
kubectl config set-context --current --namespace $namespace

```

### Log pod

```powershell

kubectl logs mongo-deployment-57f698b87d-rngvl -f

## By Label

kubectl logs -l app=mongopod -f

```

### Port forward to Mongo-express

```powershell

kubectl port-forward service/mongoexpress-service 5555:8081

```



### Pod watcher types


- replicaset (deployment) (Scale)
- daemonset ()
- statefulset (data driven containers)


### 

### Rollout restart

```powershell

kubectl rollout restart deployment.apps/deploymentname

```