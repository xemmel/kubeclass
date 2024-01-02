## Clone repo

```powershell

git clone https://github.com/xemmel/kubeclass.git
```


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

