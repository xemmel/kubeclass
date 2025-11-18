## 

```bash

kind get clusters
### delete existing cluster
kind delete cluster --name clustername

### Create new cluster 
kind create cluster --name multicluster --config cluster.yaml

kubectl get nodes

#### Create namespace
kubectl create namespace demo
kubectl config set-context --current --namespace demo

### Apply deployment
kubectl apply --filename deployment.yaml

#### Existing deployment.yaml

kubectl scale deployment webserver-deployment --replicas 5


### Check pod distribution
kubectl get pods -o wide

### Get all api-resources
kubectl api-resources

```



### Maintanance

```bash

### Unschedule node (No drain)
kubectl cordon multicluster-worker3

## Reschedule node
kubectl uncordon multicluster-worker3

## Drain node (will also cordon)
kubectl drain multicluster-worker2 --ignore-daemonsets


### rollout restart
kubectl rollout restart deployment webserver-deployment

```