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