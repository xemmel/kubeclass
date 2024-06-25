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


### Deploy two applications

```powershell

#### Clean up
kubectl delete namespace test01

kubectl create namespace test01

kubectl apply -f .\Templates\application1.yaml

kubectl apply -f .\Templates\application2.yaml

## application 1 will NOT work, because it is dependent on a configMap!!

kubectl apply -f .\Templates\configMap.yaml

## Now it should work

kubectl port-forward service/thetest-service 5000:80
kubectl port-forward service/thetest2-service 5001:80

### Open in browser
localhost:5000



```


## Create multi server cluster

```powershell

kind delete cluster --name kind

## goto folder: Courses\20240624\kindTemplates

kind create cluster --name multinodes --config .\multiworker.yaml

### Verify multi nodes

kubectl get nodes

## goto folder: Courses\20240624

kubectl apply -f .\Templates\deployment.yaml

### verify pods on diff nodes

kubectl get pods -o wide

```


#### Maintanance

```powershell

### Stop scheduling

kubectl cordon multinodes-worker2

### start scheduling

kubectl uncordon multinodes-worker2

### drain

kubectl drain --ignore-daemonsets multinodes-worker2 --force

```


### Create secret from kubectl

```powershell

kubectl create secret generic test-secret --from-literal=ftppassword=verysecretagain


```

### Show log for individual pod

```powershell

kubectl logs mortenstest2-deployment-858648f8c9-8sjvg -f

```

### shwo log for all pods by label

```powershell

kubectl logs -l app=thetest2 -f

```


### Volume

```powershell

### create cluster

## goto folder: Courses\20240624\kindTemplates

kind create cluster --name volumecluster --config .\volumecluster.yaml


## goto folder: Courses\20240624

### Deploy the pvc

kubectl apply -f .\Templates\elasticpvc.yaml

#### Check pv, pvc

kubectl get pv,pvc

### Deploy the elasticsearch (which uses pvc, therefore creates a pv (and a local folder))

kubectl apply -f .\Templates\elasticsearch.yaml

### Log the elasticsearch (late starter)

kubectl logs -l app=elastic -f

### Check the folder and pvc,pv again


### Port forward

kubectl port-forward service/elastic-service 9200:9200

### ES commands

#### List indices

curl 127.0.0.1:9200/_cat/indices

#### Create index

curl 127.0.0.1:9200/myindex -X PUT

```


## Ingress


```powershell

### create cluster

kind create cluster --name ingresscluster --config .\ingress.yaml

### install ingress controller

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

### Apply app1 and app2

kubectl apply -f .\Templates\Ingress\application1.yaml

kubectl apply -f .\Templates\Ingress\application2.yaml

### Apply ingress

kubectl apply -f .\Templates\Ingress\ingress.yaml

browse: localhost/app1


```



### Helm

```powershell

winget install Helm.Helm

### Inside the folder: Courses\20240624\Helm

helm install app3 .\ApplicationChart\ --set app.name=app3 --set app.title=theapp3 --namespace app3 --create-namespace

```

