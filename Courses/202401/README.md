
## Table of Content
- [Table of Content](#table-of-content)
- [Clone repo](#clone-repo)
- [Create namespace](#create-namespace)
- [Apply pod](#apply-pod)
  - [Verify pod running](#verify-pod-running)
  - [WATCH!!!](#watch)
  - [Install debug pod](#install-debug-pod)
  - [Exec into debug pod](#exec-into-debug-pod)
  - [Exec into pod](#exec-into-pod)


## Clone repo

```powershell

git clone https://github.com/xemmel/kubeclass.git
```

[Back to top](#table-of-content)

## Create namespace


```powershell
$namespace = "yournamespace";

kubectl create namespace $namespace;

### Set kubectl pointer to your namespace
kubectl config set-context --current --namespace $namespace

```



## Apply pod


- Create pod.yaml

```yaml

apiVersion: v1
kind: Pod
metadata:
  name: forca2024-pod
spec:
  containers:
    - name: helloworld-container
      image: mcr.microsoft.com/azuredocs/aks-helloworld:v1

```

kubectl apply -f ./Templates/pod.yaml


### Verify pod running

kubectl get pods

### WATCH!!!

kubectl get pods --watch


### Install debug pod

```powershell

kubectl apply -f https://raw.githubusercontent.com/xemmel/kubeclass/master/Templates/Debug/curlpod.yaml

```

### Exec into debug pod

```powershell

kubectl exec -it pod -n debug -- bash

```

### Exec into pod

kubectl exec -it podname -- bash