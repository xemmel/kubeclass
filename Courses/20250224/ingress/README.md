```powershell

kind get clusters 

kind delete cluster --name ???

kind create cluster --name ingress --config .\kind_cluster_ingress.yaml


kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

```


```powershell

curl localhost/appx

http://localhost/elastic/_cat/indices

```