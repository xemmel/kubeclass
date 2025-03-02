### Create multiserver cluster

```powershell

kind delete cluster

kind create cluster --name multi --config .\kind_cluster_multiple_nodes.yaml

kubectl get nodes

kubectl get pods -o wide

```


### Maintanance

```powershell

#### Unschedule (cordon)
kubectl cordon multi-worker3

#### Drain
kubectl drain --ignore-daemonsets multi-worker3

#### ready for work again
kubectl uncordon multi-worker3

#### Re-distribute all pods
kubectl rollout restart deployment.apps/appx-deployment



```


#### Logging

```powershell

kubectl logs -l app=appx -f

```

#### Delete cluster (Kind)

```powershell

kind delete cluster --name multi

kind create cluster --name volume --config .\kind_cluster_volume.yaml



```