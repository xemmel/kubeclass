### Windows/Linux

### Hello world web page

```powershell

$helloWorldImage = "mcr.microsoft.com/azuredocs/aks-helloworld:v1";

HELLOWORLDIMAGE="mcr.microsoft.com/azuredocs/aks-helloworld:v1"

```


### Create namespace

```powershell

$namespace = "firsttest";

NAMESPACE="firsttest"

kubectl create namespace $namespace;

kubectl create namespace $NAMESPACE



### switch context to namespace

kubectl config set-context --current --namespace $namespace;

kubectl config set-context --current --namespace $NAMESPACE


```

### Create debug pod

```powershell

kubectl create namespace debugpod

kubectl run debugpod --image nginx --namespace debugpod


```

### Use Debug pod

```powershell

kubectl exec -it debugpod --namespace debugpod -- bash

```

### Delete debug pod

```powershell

kubectl delete namespace debugpod

```

### Create pod manually

```powershell

kubectl run helloworldpod --image $helloWorldImage --env="TITLE=WELCOME TO KUBE CLASS!"

kubectl run helloworldpod --image $HELLOWORLDIMAGE --env="TITLE=WELCOME TO KUBE CLASS!"

```

### Create Deployment/Service/(Ingress)

```powershell

kubectl create deployment helloworlddeployment `
     --image=$helloWorldImage `
     --replicas=3 
;

kubectl create deployment helloworlddeployment \
     --image=$HELLOWORLDIMAGE \
     --replicas=3


### Dry run to create yaml

kubectl create deployment helloworlddeployment `
     --image=$helloWorldImage `
     --replicas=3 `
     --dry-run=client `
     --output yaml
;

kubectl create deployment helloworlddeployment \
     --image=$HELLOWORLDIMAGE \
     --replicas=3 \
     --dry-run=client \
     --output yaml >> deploymentsample.yaml



```



### Upload image to kind nodes

```powershell

kind load docker-image failingwebapi:0.3 --name ingress

```



### Delete namespace

```powershell

kubectl delete namespace $namespace;

```


#### password reminder to Windows Servers

3 capital

EscapeMovie  LastSongOnKuwaitAlbum WhereAmIDanishAbb TwoYearsAfterRYouTube Bang

