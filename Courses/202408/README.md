
```powershell


$namespace = "demo1"

kubectl create namespace $namespace

## Change context to another namespace

kubectl config set-context --current --namespace $namespace


kubectl apply --filename .\deployment.yaml
kubectl apply --filename .\service.yaml


## Show all pods, services, deployment, replicasets

kubectl get all  

### Change no. of replicas

kubectl apply --filename .\deployment.yaml

### Describe service
kubectl describe service thethird-service

### Verify endpoints

kubectl get pods -o wide


```



### Create debug pod

```powershell

kubectl create namespace debugpod

kubectl run debugpod --image nginx --namespace debugpod


```

### Use Debug pod

```powershell

kubectl exec -it debugpod --namespace debugpod -- bash

```