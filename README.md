## Kubernetes class
## Morten la Cour

## Getting started

### install Chocolatey

In Powershell (Administrator
)
```powershell


Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

```

### install Powershell 7

```powershell

choco install powershell-core -y

```

### install software (In Powershell 7/Core)

```powershell

choco install kubernetes-cli -y
choco install vscode -y
choco install kubernetes-helm -y
choco install diffutils -y

```

### Use Azure or Kind



### Test the connection 

```powershell

kubectl get nodes

```

#### Create a namespace

```powershell
kubectl create namespace name_of_namespace
```

### Sample Image public

mcr.microsoft.com/azuredocs/aks-helloworld:v1


## Create first application (Single Pod)

```powershell
$namespace = "app1";
kubectl create namespace $namespace;
kubectl run $namespace --image mcr.microsoft.com/azuredocs/aks-helloworld:v1 --namespace $namespace;

```

## Create first application (Deployment)
> A deployment is a **ReplicaSet** wrapper for controlled *updates*

```powershell

$namespace = "app1";
kubectl create namespace $namespace;

kubectl create deployment $namespace-deployment `
     --image=mcr.microsoft.com/azuredocs/aks-helloworld:v1 ` --replicas=3

```

## Switch to namespace

```powershell
kubectl config set-context --current --namespace $namespace
```

## Switch between context (clusters)

```powershell
kubectl config use-context iitaks
```

## Verify Pod is running

```powershell
kubectl get all
```

## See detailed Pod 

```powershell
kubectl get pods -o wide
```

### Log Pod

```powershell
kubectl logs pod/$namespace [-f]
```

### Create Service for pod (Cloud Provider)

```powershell
kubectl expose pod $namespace --port=80 --name=$namespace-service --type LoadBalancer;
```

### Create Service for pod (Local)

```powershell

kubectl expose pod $namespace --port=80 --name=$namespace-service --type ClusterIP;

### Forward it
kubectl port-forward service/$namespace-service 4000:80
```

### Create Service for Deployment (local)

```powershell

kubectl expose deployment $namespace-deployment `
    --type ClusterIP `
    --name $namespace-service `
    --port 80
;

```


### List all

```powershell
kubectl get all
```
### Test Service

```powershell
Invoke-Webrequest 1.1.1.1/names
```

### Examine Service 

```powershell
kubectl describe service/$namespace-service
```
Compare the **Endpoints** *ip-address* to the pod's internal *ip-address*

```powershell
kubectl get pods -o wide
```
### Clean up

```powershell
kubectl delete namespace $namespace
```

### Deploy Templates

```powershell
kubectl apply -f TemplatePath\Template.yaml
```

### Rollout (force restart of all pods (configMaps, secret))

```powershell
kubectl rollout restart deployment.apps/your_deployment_name_here

```

POD   :-(

kubectl describe [pod] podname
  -> METADATA POD LOG

 POD :-)

Unexpected result!
log container
kubectl logs podname [-f] (follow -> Live tracke)


kubectl exec -> Inject commands into pod
kubectl exec -it [podname] --namespace debug -- bash









env: [ { "name" : "TITLE", "value" : "HELLO"},{ "some"	}]






DRY RUN / DIFF

## Check syntax
kubectl apply -f ..... --dry-run=client 

## Check changes on server
kubectl apply -f .... --dry-run=server
   unchanged
   configured -> Changes will take place

## Actual yaml diff (Require diff tool)
kubectl diff -f ...



## DRAIN (Maintanance)

kubectl drain --ignore-daemonsets --force [node name]

## Release for scheduling

kubectl uncordon [node name]



### Secrets 

kubectl create secret generic demo2-secret --from-literal=thepassword=verysecret




FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build-env
WORKDIR /App

# Copy everything
COPY . ./
# Restore as distinct layers
RUN dotnet restore
# Build and publish a release
RUN dotnet publish -c Release -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:7.0
WORKDIR /App
COPY --from=build-env /App/out .
ENTRYPOINT ["dotnet", "mywebapi.dll"]




## Docker volume

docker run -dit -p 7779:80 -v C:\mounts\nginx:/usr/share/nginx/html  myownempyapp:1.0

