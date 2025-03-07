#### Cluster config

> multi_cluster.yaml
```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
- role: worker
```


#### Create cluster

```powershell
kind get clusters

kind delete cluster --name **clustername**
kind create cluster --name multi --config multi_cluster.yaml


### Deploy a deployment with x replicas

kubectl get pods -o wide
```