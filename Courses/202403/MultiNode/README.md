## Setup

- kind get clusters

- kind delete cluster --name kind

- kind_clusters -> kind create cluster --name multinodes --config .\multi_nodes.yaml

- kubectl get nodes

- Create namespace

- Deployment_Exercise -> deployment.yaml / service.yaml


- kubectl get nodes -o wide 


### Cordon (stop new pod creation)

```powershell

kubectl cordon node_name

```

### Uncordon (Allow schedule again)

```powershell

kubectl uncordon node_name

```

### Drain

```powershell

kubectl drain --ignore-daemonsets --force node_name

``` 


