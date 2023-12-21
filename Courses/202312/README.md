
## Table of content




### Create pod

```powershell

### Create namespace
$namespace = "yournamespacename";

kubectl create namespace $namespace;


### switch context to namespace

kubectl config set-context --current --namespace $namespace;

### Create a pod

kubectl run pod1 --image mcr.microsoft.com/azuredocs/aks-helloworld:v1

### Describe a pod

kubectl describe pod pod1


### Remove a pod

kubectl delete pod pod1



```

