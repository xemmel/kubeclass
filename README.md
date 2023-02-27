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


## Create first application

```powershell
$namespace = "app1";
kubectl create namespace $namespace;
kubectl run $namespace --image mcr.microsoft.com/azuredocs/aks-helloworld:v1 --namespace $namespace;

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
