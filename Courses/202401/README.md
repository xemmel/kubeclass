
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
  - [Delete pod](#delete-pod)
  - [Apply manifest](#apply-manifest)
  - [Describe service](#describe-service)
- [Maintanance](#maintanance)
- [Not Scheduled (Tainted)](#not-scheduled-tainted)
- [Scheduled (Untainted)](#scheduled-untainted)
- [Drain](#drain)
  - [Restart Deployment](#restart-deployment)
  - [Port forward](#port-forward)
  - [Create secret from kubectl](#create-secret-from-kubectl)


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


### Delete pod

kubectl delete pod podname

### Apply manifest

```powershell

kubectl apply -f ./..../file.yaml

```

### Describe service

```powershell

kubectl describe service/servicename 

```

## Maintanance

## Not Scheduled (Tainted)

kubectl cordon themulticluster-worker2


## Scheduled (Untainted)
kubectl uncordon themulticluster-worker2


## Drain

kubectl drain --ignore-daemonsets --force themulticluster-worker2


### Restart Deployment

```powershell

kubectl rollout restart [deploymentname]

```


### Port forward

```powershell

kubectl port-forward service/servicename 4343:80

kubectl port-forward service/forca2024-service 4343:80

```

### Create secret from kubectl

```powershell

kubectl create secret generic forca2024-secret --from-literal=webtitle="a very secret powershell title"

```

