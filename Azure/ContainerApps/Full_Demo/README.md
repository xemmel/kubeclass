## Container App

### Init

```bash
SUBSCRIPTIONID="9bc198aa-089c-4698-a7ef-8af058b48d90"
APPNAME="fridaymlc"
LOCATION="swedencentral"
```

### Files

#### requirements.txt

```
fastapi[standard]
```

#### Dockerfile

```dockerfile
FROM python:3.14

WORKDIR /code

COPY ./requirements.txt /code/requirements.txt

RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

COPY . /code/app

CMD ["fastapi", "run", "app/webapi.py", "--port", "80"]

```

#### webapi.py

```python
from fastapi import FastAPI

app = FastAPI()


@app.get("/version")
def get_version():
    return { "version" : "1.0" }
```

#### Create all

```bash
cat<<EOF>>requirements.txt
fastapi[standard]
EOF

cat<<EOF>>Dockerfile
```dockerfile
FROM python:3.14

WORKDIR /code

COPY ./requirements.txt /code/requirements.txt

RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

COPY . /code/app

CMD ["fastapi", "run", "app/webapi.py", "--port", "80"]
EOF

cat<<EOF>>webapi.py
from fastapi import FastAPI

app = FastAPI()


@app.get("/version")
def get_version():
    return { "version" : "1.0" }
EOF

```

### Create Resource Group

```bash
az group create \
  --subscription $SUBSCRIPTIONID \
  --name "rg-${APPNAME}" \
  --location $LOCATION
```

### Create Container Registry

```bash
ACR=$(az acr create \
  --subscription $SUBSCRIPTIONID \
  --resource-group "rg-${APPNAME}" \
  --name $APPNAME \
  --sku Basic \
  --location $LOCATION
)


ACR_ID=$(echo $ACR | jq .id -r)
ACR_SERVER=$(echo $ACR | jq .loginServer -r)

echo $ACR_ID
echo $ACR_SERVER

```

### User Managed Identity

```bash
MID=$(az identity create \
  --subscription $SUBSCRIPTIONID \
  --resource-group "rg-${APPNAME}" \
  --name "id-${APPNAME}" \
  --location $LOCATION)

MID_ID=$(echo $MID | jq .id -r)
MID_PRINCIPALID=$(echo $MID | jq .principalId -r)

echo $MID_ID

```

### RBAC AcrPull

```bash
az role assignment create \
  --subscription $SUBSCRIPTIONID \
  --role "AcrPull" \
  --scope $ACR_ID \
  --assignee $MID_PRINCIPALID

```

### Build and push image

```bash
az acr build \
  --subscription $SUBSCRIPTIONID \
  --registry $APPNAME \
  --image "${ACR_SERVER}/wapi:1.0" \
  .

```

### Create Container Environment

```bash
az containerapp env create \
  --subscription $SUBSCRIPTIONID \
  --resource-group "rg-${APPNAME}" \
  --name "aca-env-${APPNAME}" \
  --location $LOCATION
```

### Create Container App

```bash
ACA=$(az containerapp create \
  --subscription $SUBSCRIPTIONID \
  --resource-group "rg-${APPNAME}" \
  --name "aca-${APPNAME}" \
  --environment "aca-env-${APPNAME}" \
  --registry-identity $MID_ID \
  --registry-server $ACR_SERVER \
  --image "${ACR_SERVER}/wapi:1.0" \
  --user-assigned $MID_ID \
  --ingress external \
  --min-replicas 0
)


ACA_INGRESS_URL=$(echo $ACA | jq .properties.configuration.ingress.fqdn -r)

```

### Test call

```bash
curl "https://${ACA_INGRESS_URL}/version"
```

### Upgrade image and container app

```bash
sed 's/1.0/1.1/g' webapi.py -i

az acr build \
  --subscription $SUBSCRIPTIONID \
  --registry $APPNAME \
  --image "${ACR_SERVER}/wapi:1.1" \
  .


az containerapp update \
  --subscription $SUBSCRIPTIONID \
  --resource-group "rg-${APPNAME}" \
  --name "aca-${APPNAME}" \
  --image "${ACR_SERVER}/wapi:1.1" \
  --no-wait

```

### Clean up

```bash
az group delete --subscription $SUBSCRIPTIONID --name "rg-${APPNAME}" --yes
```
