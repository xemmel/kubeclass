## Multi Cluster

```bash

kind get clusters

kind delete cluster --name kind

kind create cluster --name multi --config multi.yaml


kubectl get nodes


```

### Deploy existing deployment

```bash

kubectl apply --filename deployment.yaml

kubectl get pods -o wide

```

### Scale 

```bash

kubectl scale deployment webserver-deployment --replicas 6

```

### Maintanance

```bash

### Un-schedule

kubectl cordon multi-worker2

### Re-schedule

kubectl uncordon multi-worker2


### Drain the node and un-schedule

kubectl drain multi-worker2 --ignore-daemonsets


### Shuffle the deck
kubectl rollout restart deployment webserver-deployment

```