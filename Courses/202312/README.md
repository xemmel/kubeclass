
## Table of content

- [Table of content](#table-of-content)
  - [Create pod](#create-pod)
  - [Apply pod template](#apply-pod-template)
  - [Log and debug functions](#log-and-debug-functions)



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

[Back to top](#table-of-content)


### Log and debug functions

```powershell

### log single pod (-f to live log)

kubectl logs podname (-f)  

### log several pods with label

kubectl logs -l bent=forcaapp1 -f

### Execute into pod

kubectl exec -it podname -- bash

### View pods with ip-addresses

kubectl get pods -o wide

### curl [pod-ip]

```



[Back to top](#table-of-content)
