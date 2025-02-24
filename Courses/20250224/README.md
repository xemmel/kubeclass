### Create multiserver cluster

```powershell

kind delete cluster

kind create cluster --name multi --config .\kind_cluster_multiple_nodes.yaml

```