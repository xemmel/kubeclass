# Pull secrets

## Create Azure Container Registry


### Init variables

```bash
SUBSCRIPTIONID="9bc198aa-089c-4698-a7ef-8af058b48d90"
APPNAME="k8ssecrettest"
LOCATION="swedencentral"

RGNAME="rg-${APPNAME}"

```

### Create ACR

```bash

az group create --name $RGNAME --location $LOCATION --subscription $SUBSCRIPTIONID


acrjson=$(az acr create \
    --subscription $SUBSCRIPTIONID \
    --resource-group $RGNAME \
    --location $LOCATION \
    --name $APPNAME \
    --sku Basic \
    --admin-enabled true
)

```

### Get Secret

```bash

ACRSERVERNAME=$(echo $acrjson | jq .loginServer -r)
ACRUSERNAME=$(az acr credential show --subscription $SUBSCRIPTIONID --resource-group $RGNAME --name $APPNAME | jq .username -r)
ACRSECRETKEY=$(az acr credential show --subscription $SUBSCRIPTIONID --resource-group $RGNAME --name $APPNAME | jq .passwords[0].value -r)


```

## Build and push image

### Create the files and build the image on acr

```bash
mkdir tmpcode
cd tmpcode

### app.py
[ -e app.py ] && rm app.py
cat<<EOF>> app.py
from fastapi import FastAPI

app = FastAPI()

@app.get("/version")
async def getversion():
  return { "version" : "1.0" }
  
@app.get("/items/{item_no}")
async def getitembyitemno(item_no: int):
  return { "item" : { "itemNo" : item_no } }
EOF

### requirements.txt

[ -e requirements.txt ] && rm requirements.txt
echo -e "fastapi[standard]>=0.113.0,<0.114.0\npydantic>=2.7.0,<3.0.0" >> requirements.txt


### Dockerfile

[ -e Dockerfile ] && rm Dockerfile
cat<<EOF>>Dockerfile
FROM python:3.14

WORKDIR /code

COPY ./requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . /code/app

CMD ["fastapi", "run", "app/app.py", "--port", "80"]
EOF

### Build image on acr

az acr build \
  --subscription $SUBSCRIPTIONID \
  --registry $APPNAME \
  --image "testapi:1.0" .

cd -
```

## Deployment with image

### Create namespace

```bash

K8SNAMESPACE="test-azure-secrets"
kubectl create namespace $K8SNAMESPACE

```

### Create secret

```bash

kubectl create secret docker-registry \
    registry-secret \
    --namespace $K8SNAMESPACE \
    --docker-server=$ACRSERVERNAME \
    --docker-username=$ACRUSERNAME \
    --docker-password=$ACRSECRETKEY

```

### Create deployment

```bash

kubectl apply --namespace $K8SNAMESPACE --filename - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: azuresecret-deployment
spec:
  selector:
    matchLabels:
      app: azuresecret
  template:
    metadata:
      labels:
        app: azuresecret
    spec:
      containers:
        - name: azuresecret-container
          image: $ACRSERVERNAME/testapi:1.0
---
apiVersion: v1
kind: Service
metadata:
  name: azuresecret
spec:
  selector:
    app: azuresecret
  ports:
    - name: http
      port: 80
      targetPort: 80
EOF


```

### Describe pull error

```bash

kubectl describe --namespace $K8SNAMESPACE $(kubectl get pods --namespace $K8SNAMESPACE -o name)

```

### Fix pull error

```bash

kubectl apply --namespace $K8SNAMESPACE --filename - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: azuresecret-deployment
spec:
  selector:
    matchLabels:
      app: azuresecret
  template:
    metadata:
      labels:
        app: azuresecret
    spec:
      containers:
        - name: azuresecret-container
          image: $ACRSERVERNAME/testapi:1.0
      imagePullSecrets:
        - name: registry-secret
---
apiVersion: v1
kind: Service
metadata:
  name: azuresecret
spec:
  type: NodePort
  selector:
    app: azuresecret
  ports:
    - name: http
      port: 80
      targetPort: 80
EOF


```

## Test

```bash

WORKERIP=$(kubectl get nodes -o wide | grep -i worker | awk '{ print $6 }')
SERVICEPORT=$(kubectl get services -A | grep -i azuresecret | awk '{ print $6 }' | awk -F":" '{ print $2 }' | awk -F"/" '{ print $1 }')

curl $WORKERIP:$SERVICEPORT/version
curl $WORKERIP:$SERVICEPORT/items/1234


## Cleanup

### Remove Resource Group

```bash

rm -rf tmpcode

az group delete --subscription $SUBSCRIPTIONID --name $RGNAME --yes

```