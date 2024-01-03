```powershell

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

```


#### Helm install

```powershell

helm install ingressdemo .\HelmChart --namespace ingress1 --create-namespace

```