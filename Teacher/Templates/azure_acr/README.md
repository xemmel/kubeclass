### Kubernetes and ACR


#### Install dotnet sdk 9 on ubuntu

```bash

sudo add-apt-repository ppa:dotnet/backports

sudo apt-get update && \
  sudo apt-get install -y dotnet-sdk-9.0
  
```

[Back to top](#kubernetes-and-acr)


#### Create ACR

##### Linux

```bash

RGNAME="rg-acr-kubernetes-remove"
LOCATION="northeurope"

az group create --name $RGNAME --location $LOCATION

ACRJSON=$(az acr create \
  --resource-group $RGNAME \
  --name acrkubernetesmlc \
  --sku Basic \
  --admin-enabled true
  )
  
ACRPASSWORDS=$(az acr credential show --name acrkubernetesmlc)
ACRPASSWORD=$(echo $ACRPASSWORDS | jq .passwords[0].value -r)
ACRID=$(echo $ACRJSON | jq .id -r)


```

[Back to top](#kubernetes-and-acr)

##### Powershell

```powershell

$rgName = "rg-acr-kubernetes-remove";
$location = "northeurope";

az group create --name $rgName --location $location

$acrJson = az acr create `
  --resource-group $rgName `
  --name acrkubernetesmlc `
  --sku Basic `
  --admin-enabled false
  
$acr = $acrJson | ConvertFrom-Json;



```

[Back to top](#kubernetes-and-acr)

#### Build image

##### Linux

```bash

az acr build \
   --registry acrkubernetesmlc \
   --image webapp:1.0 \
   .

```

[Back to top](#kubernetes-and-acr)

##### Powershell

```powershell

mkdir imagetemp

cd imagetemp

mkdir html

cd html

echo "<html>`r`n`t<body>`r`n`t`t<h1>Hello From Container</h1>`r`n`t</body>`r`n</html>" >> index.html

cd -

echo "FROM nginx`r`nCOPY html /usr/share/nginx/html" >> Dockerfile

az acr build `
  --registry acrkubernetesmlc `
  --image webapp:1.0 `
  .

cd -

sleep(1)

get-item imagetemp | remove-item -force -recurse


```

[Back to top](#kubernetes-and-acr)

#### Image name


```
acrkubernetesmlc.azurecr.io/webapp:1.0

```

[Back to top](#kubernetes-and-acr)

#### Connect to Mg

```powershell

Connect-MgGraph


```

[Back to top](#kubernetes-and-acr)

#### Create Service Principal

```powershell


$app = New-MgApplication -DisplayName "acrapp"

$appSecret = Add-MgApplicationPassword -ApplicationId $app.Id
$secret = $appSecret.SecretText

$sp = New-MgServicePrincipal -AppId $app.AppId


```

[Back to top](#kubernetes-and-acr)

#### Create RBAC

##### Linux

> $sp.id


```bash

az role assignment create \
  --role AcrPull \
  --scope $ACRID \
  --assignee ebddc15c-850d-492e-b30a-59dd10fe6ff5


```

[Back to top](#kubernetes-and-acr)

##### Powershell

```powershell

az role assignment create `
  --role AcrPull `
  --scope $acr.id `
  --assignee $sp.id
  

```

[Back to top](#kubernetes-and-acr)


#### Create kind cluster

```bash

multipass launch --name kind --disk 10G --memory 1G --cpus 2

multipass shell kind

```

[Back to top](#kubernetes-and-acr)

##### Install kind on server

###### Update

```bash

sudo apt update

sudo apt upgrade -y

```

[Back to top](#kubernetes-and-acr)

###### Docker

```bash

sudo apt install docker.io -y

sudo usermod -aG docker $USER
newgrp docker

```

[Back to top](#kubernetes-and-acr)


###### kind

```bash

curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.29.0/kind-linux-amd64

chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

```

[Back to top](#kubernetes-and-acr)

###### Kubectl 

```bash

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

chmod +x kubectl
mkdir -p ~/.local/bin
mv ./kubectl ~/.local/bin/kubectl

### kubectl completion

sudo apt-get install -y bash-completion
echo "source <(kubectl completion bash)" >> ~/.bashrc
source ~/.bashrc


```
[Back to top](#kubernetes-and-acr)

###### Create cluster

```bash

kind create cluster

```

[Back to top](#kubernetes-and-acr)

#### Create template without secret

```bash

cat << EOF >> deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-deployment
spec:
  selector:
    matchLabels:
     app: test
  template:
    metadata:
      labels:
        app: test
    spec:
      containers:
        - name: test-container
          image: acrkubernetesmlc.azurecr.io/webapp:1.0
EOF


kubectl create namespace test01
kubectl config set-context --current --namespace test01

kubectl apply --filename deployment.yaml


```

[Back to top](#kubernetes-and-acr)

#### Create secret syntax 

```powershell

echo "kubectl create secret docker-registry azure-secret \`r`n--docker-server=acrkubernetesmlc.azurecr.io \`r`n--docker-username=$($app.AppId) \`r`n--docker-password=$secret`r`n" | 
	Set-Clipboard | 
	Get-Clipboard


```

[Back to top](#kubernetes-and-acr)

### Secret in pod

```yaml
  containers
  
  
  imagePullSecrets:
    - name: azure-secret

```

[Back to top](#kubernetes-and-acr)

#### Create secret in deployment.yaml

```bash

cat << EOF >> deployment.yaml
      imagePullSecrets:
        - name: azure-secret
EOF

kubectl apply --filename deployment.yaml


```
[Back to top](#kubernetes-and-acr)

### Clean up


```powershell

az group delete --yes --no-wait --name $rgName;

Remove-MgApplication -ApplicationId $app.Id




```


[Back to top](#kubernetes-and-acr)