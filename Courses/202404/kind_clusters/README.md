## Create Cluster

```powershell

kind create cluster --name multinodes --config .\multi_nodes.yaml
kind create cluster --name ingress --config .\ingress.yaml


```


### Ingress Controller

```powershell

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

curl localhost  -> nginx 404

```