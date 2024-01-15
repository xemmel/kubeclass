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