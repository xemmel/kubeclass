## Install kind

```powershell

winget install Kubernetes.kind

### test

kubectl get namespaces


```


### Install

```powershell

#### Install Powershell 7
winget install Microsoft.PowerShell

#### Install git (will require restart of powershell)

winget install Git.Git
winget install Microsoft.VisualStudioCode

### Restart powershell

#### Git clone (in a parent folder you want to use)

git clone https://github.com/xemmel/kubeclass.git

```


#### Create first deployment


```powershell

### Create namespace 
kubectl create namespace test01

### Switch kubectl to "test01" namespace

kubectl config set-context --current --namespace test01

### Create first deployment (in folder right outside /Templates) (..\kubeclass\Courses\20240624)

kubectl apply -f .\Templates\deployment.yaml


### open VS code
code .

### Manipulate your template (deployment.yaml) change replica no.

### Reapply your template

```

### View deployment/pods/replicaset


```powershell

kubectl get all

### View pod IP-addresses and nodes

kubectl get pods -o wide


```


### Deploy a Service

```powershell

## ..\kubeclass\courses\2024....

git pull

kubectl apply -f .\Templates\service.yaml

kubectl get all


### examine the endpoints behind the service
kubectl describe service/thetest-service

```