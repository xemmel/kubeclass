
## Table of content

- [Table of content](#table-of-content)
  - [Create pod](#create-pod)
  - [Apply pod template](#apply-pod-template)



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

[Back to top](#table-of-content)


### Apply pod template

```yaml

apiVersion: v1
kind: Pod
metadata:
  name: forcapod7
spec:
  containers:
  - image: nginx
    name: forcapod7



```

```powershell

### Apply template
kubectl apply -f .....

### Delete artifacts inside the template
kubectl delete -f .....


```