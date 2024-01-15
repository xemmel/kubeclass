### Create pod from kubectl

```powershell

$namespace = "teknodemo01"

kubectl create namespace $namespace

## Switch context to namespace

kubectl config set-context --current --namespace $namespace

## Create pod

kubectl run myfirstcontainer --image mcr.microsoft.com/azuredocs/aks-helloworld:v1

kubectl get pods


## Execute into pod

kubectl exec -it myfirstcontainer -- bash




```


### Deploy manifest (.yaml file)


```powershell

kubectl apply -f .\Templates\singlepod.yaml

```


### Git commands

```powershell

git clone https://github.com/xemmel/kubeclass.git


git pull


```


### get manifest into clipboard

```powershell

kubectl run myfirstcontainer2 --image mcr.microsoft.com/azuredocs/aks-helloworld:v1 --dry-run=client -o yaml | Set-Clipboard

```


### Inject command into pod

```powershell

### Change context into pod

kubectl exec -it *podname* -- bash


### http get service

curl *servicename*

```


### Port forward (Expose Service)

```powershell

kubectl port-forward service/helloworldapp2-service 5000:80

```


### Restart all pods in a deployment


```powershell

kubectl rollout restart deployment.apps/helloworldapp2-deployment

```