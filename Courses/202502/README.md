## Feb. 2025


### Create debug pod 
```powershell

kubectl create namespace debugpod

kubectl run debugpod --image nginx --namespace debugpod

```

### Use Debug pod

```powershell

kubectl exec -it debugpod --namespace debugpod -- bash

```

### Curl service other namespace

```powershell

curl [serviceName].[nameSpaceName]

```


#### Multi node cluster

```powershell

### remove old cluster
kind delete cluster

### Create a cluster manifest for multiple worker nodes
$manifest = @"
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
- role: worker
"@;

echo $manifest >> multi.yaml

kind create cluster --config .\multi.yaml

### Create a namespace
kubectl create namespace appx
### Switch context
kubectl config set-context --current --namespace appx
### Create deployment/service
....



kubectl get all

### get all pods with ip address and node
kubectl get pods -o wide
```

### Maintanance

```powershell

## Unschedule (cordon)
kubectl cordon [nodename]

### "Shuffle" the deck
kubectl rollout restart deployment.apps/simple-deployment

## Schedule again
kubectl uncordon [nodename]

### Drain (Evict all existing pods and unschedule)
kubectl drain [nodename] --ignore-daemonsets



```