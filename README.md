## Kubernetes class
## Morten la Cour

## Getting started

### install Chocolatey

In Powershell (Administrator
)
```powershell


Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

```

### install Powershell 7 (optional)

```powershell
choco install powershell-core -y
```

### install software (Beginner)

```powershell

choco install azure-cli -y
choco install kubernetes-cli -y
choco install vscode -y
```

### install software (Advanced)

```powershell
choco install kubernetes-helm -y
```

### login to Azure

```powershell

az login -u "kube1@integration-it.com" -p "...."

```

### Get kubernetes Cluster API Key Certificate

```powershell
az aks get-credentials --name iitaks  --resource-group rg-aks --overwrite-existing;
```

### Test the connection (Create your namespace)

```powershell
kubectl create namespace name_of_namespace
```

## Create first application

```powershell
$namespace = "app1";
kubectl create namespace $namespace;
kubectl run $namespace --image iitaks.azurecr.io/asyncapi:1.1 --namespace $namespace;
```

## Switch to namespace

```powershell
kubectl config set-context --current --namespace $namespace
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

### Create Service for pod

```powershell
kubectl expose pod $namespace --port=80 --name=$namespace-service --type LoadBalancer;
```
### List all

```powershell
kubectl get all
```
### Test Service

```powershell
Invoke-Webrequest 1.1.1.1/names
```

### Deploy Templates

```powershell
kubectl apply -f TemplatePath\Template.yaml
```