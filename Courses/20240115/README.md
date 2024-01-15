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