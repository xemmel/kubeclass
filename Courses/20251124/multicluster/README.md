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