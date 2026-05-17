# OIDC Advanced

## Certbot


subscriptionId="4bf83030-fffb-4e17-8ec3-faacdf8634e5"
dnsZone="learn-kubernetes.com"
rgName="rg-dns-learn-kubernetes"


### View all existing record-sets

az network dns record-set list \
  --subscription $subscriptionId \
  --resource-group $rgName \
  --zone-name $dnsZone \
  --output table
  

  ### View all existing txt records

az network dns record-set txt list \
  --subscription $subscriptionId \
  --resource-group $rgName \
  --zone-name $dnsZone \
  --output table

  
  
### Delete txt record

read -p "subdomain to delete: " subdomain

az network dns record-set txt delete \
  --subscription $subscriptionId \
  --resource-group $rgName \
  --zone-name $dnsZone \
  --name "_acme-challenge.${subdomain}" \
  --yes

  
### Delete txt record fullname

read -p "subdomain to delete (fullname): " fullname

az network dns record-set txt delete \
  --subscription $subscriptionId \
  --resource-group $rgName \
  --zone-name $dnsZone \
  --name $fullname \
  --yes
    
  
  ### install certbot
  


sudo apt install certbot -y

sudo apt install bind9-dnsutils -y



read -p "subdomain: " subdomain

sudo certbot certonly \
  --manual \
  --preferred-challenges dns \
  -d "${subdomain}.${dnsZone}"

  
read -p "Enter txt value: " key
  
az network dns record-set txt create \
  --subscription $subscriptionId \
  --resource-group $rgName \
  --zone-name $dnsZone \
  --name "_acme-challenge.${subdomain}"

az network dns record-set txt add-record \
  --subscription $subscriptionId \
  --resource-group $rgName \
  --zone-name $dnsZone \
  --record-set-name "_acme-challenge.${subdomain}" \
  --value $key

  
  



nslookup -type=TXT "_acme-challenge.${subdomain}.${dnsZone}"





## kubernetes secret

mkdir tmpsecret 
sudo cp "/etc/letsencrypt/live/${subdomain}.${dnsZone}/fullchain.pem" ./tmpsecret/fullchain.pem
sudo cp "/etc/letsencrypt/live/${subdomain}.${dnsZone}/privkey.pem" ./tmpsecret/privkey.pem

sudo chmod 777 ./tmpsecret/privkey.pem
sudo chmod 777 ./tmpsecret/fullchain.pem


kubectl create namespace demo-app

kubectl create secret tls subdomain-secret \
    --namespace demo-app \
  --cert="./tmpsecret/fullchain.pem" \
  --key="./tmpsecret/privkey.pem"
  
  
  
### Create k8s deployment and service

```bash

kubectl apply --namespace demo-app --filename - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demoapp-deployment
spec:
  selector:
    matchLabels:
      app: demoapp
  template:
    metadata:
      labels:
        app: demoapp
    spec:
      initContainers:
        - name: init-html
          image: busybox
          command:
            - sh
            - -c
            - echo "Welcome to demoapp" > /usr/share/nginx/html/index.html
          volumeMounts:
            - name: html
              mountPath: /usr/share/nginx/html
      containers:
        - name: main-container
          image: nginx
          volumeMounts:
            - name: html
              mountPath: /usr/share/nginx/html
      volumes: 
        - emptyDir: {}
          name: html
---
apiVersion: v1
kind: Service
metadata:
  name: demoapp
spec:
  type: NodePort
  selector:
    app: demoapp
  ports:
    - name: http
      port: 80
      targetPort: 80
EOF


```

### Test the service

```bash

workerNodeAddress=$(kubectl get nodes -o wide | grep -i worker | awk '{ print $6 }')
servicePort=$(kubectl get services -A | grep -i demo-app | grep -i nodeport | awk -F'[:/]' '{print $2}')


curl http://$workerNodeAddress:$servicePort



```


### Create demoapp gateway

```bash

kubectl apply --namespace demo-app --filename - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: demoapp-gateway
spec:
  gatewayClassName: maingatewayclass
  listeners:
    - name: test-http
      protocol: HTTP
      port: 80
      allowedRoutes:
        namespaces:
          from: All      
    - name: main-https
      protocol: HTTPS
      port: 443
      hostname: "${subdomain}.${dnsZone}"
      allowedRoutes:
        namespaces:
          from: All 
      tls:
        certificateRefs:
          - kind: Secret
            group: ""
            name: subdomain-secret

EOF


```


### Create HTTPRoute for demo-app


```bash
kubectl apply --namespace demo-app --filename - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: hello-httproute
spec:
  parentRefs:
  - name: demoapp-gateway
  rules:
    - backendRefs:
      - name: demoapp
        kind: Service
        port: 80
      matches:
        - path:
            type: PathPrefix
            value: /demoapp
      filters:
        - type: URLRewrite
          urlRewrite:
            path:
              type: ReplaceFullPath
              replaceFullPath: /
EOF

```

### Test demoapp through httproute

```bash

gatewayPort=$(kubectl get services -A | grep -i demoapp-gateway | awk -F'[:/]' '{print $2}')
tlsGatewayPort=$(kubectl get services -A | grep -i demoapp-gateway | awk -F'[:/]' '{print $4}')

## Try with normal http port 80

curl "http://${workerNodeAddress}:${gatewayPort}/demoapp"

## Try with https (tls)

### Add subdomain to hosts file
echo "${workerNodeAddress}   ${subdomain}.${dnsZone}" | sudo tee -a /etc/hosts

nslookup "${subdomain}.${dnsZone}"

## Remove it

sudo sed '$d' /etc/hosts -i



curl "https://${workerNodeAddress}:${tlsGatewayPort}/demoapp"


### Will not work, we need hostname 

curl "https://${subdomain}.${dnsZone}:${tlsGatewayPort}/demoapp"

echo "https://${subdomain}.${dnsZone}:${tlsGatewayPort}/demoapp"






```


### Create a logon app

```bash

cat<<EOF>>app.py
import os
import json
from fastapi import FastAPI
from fastapi.responses import HTMLResponse,PlainTextResponse


app = FastAPI()


@app.get("/", response_class=HTMLResponse)
async def index():
    sub_title = os.getenv("SUB_TITLE")
    subtitle_html = f" ({sub_title})" if sub_title else ""

    return f"""
    <html>
        <head><title>Logon App</title></head>
        <body>
            <h1>Logon App{subtitle_html}</h1>
            <ul>
                <li><a href="/env">Show all environment variables</a></li>
                <li><a href="/version">Version</a></li>
                <li><a href="/env/path">Filter environment variables by "path"</a></li>
                <li><a href="/docs">FastAPI docs</a></li>
            </ul>
        </body>
    </html>
    """

@app.get("/version")
async def getversion():
    return { "version" : "1.0" }


@app.get("/env", response_class=PlainTextResponse)
@app.get("/env/{mask}", response_class=PlainTextResponse)
async def getenv(mask: str | None = None):

    env = dict(os.environ)

    if mask:
        mask = mask.lower()

        env = {
            key: value
            for key, value in env.items()
            if mask in key.lower()
        }

    return json.dumps(env, indent=4, sort_keys=True)(devenv)
EOF

pip install "fastapi[standard]"

export SUB_TITLE="logapp1"
fastapi dev


```


### Create Dockerfile

```bash

[ -e requirements.txt ] && rm requirements.txt
echo -e "fastapi[standard]>=0.113.0,<0.114.0\npydantic>=2.7.0,<3.0.0" >> requirements.txt

[ -e requirements.txt ] && rm requirements.txt
echo -e "fastapi[standard]>=0.113.0,<0.114.0\npydantic>=2.7.0,<3.0.0" >> requirements.txt


[ -e Dockerfile ] && rm Dockerfile
cat<<EOF>>Dockerfile
FROM python:3.14

WORKDIR /code

COPY ./requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . /code/app

CMD ["fastapi", "run", "app/app.py", "--port", "80"]
EOF




```

### Create docker image and container

```bash

IMAGENAME="logonapp:1.0"

docker buildx build --tag $IMAGENAME .

docker run --name logonapp1 --publish 8899:80 --env x-user=clara -d $IMAGENAME

curl localhost:8899/env

docker ps -q | xargs docker rm -f


```


### Build in Azure Container registry

```bash

SUBSCRIPTIONID="9bc198aa-089c-4698-a7ef-8af058b48d90"
APPNAME="k8ssecrettest"

RGNAME="rg-${APPNAME}"


acr=$(az acr show --subscription $SUBSCRIPTIONID --resource-group $RGNAME --name $APPNAME )


acrUserName=$(az acr credential show --subscription $SUBSCRIPTIONID --resource-group $RGNAME --name $APPNAME | jq .username -r)
acrPassword=$(az acr credential show --subscription $SUBSCRIPTIONID --resource-group $RGNAME --name $APPNAME | jq .passwords[0].value -r)
acrFullName=$(echo $acr | jq .loginServer -r)


### Build and push
az acr build --subscription $SUBSCRIPTIONID --resource-group $RGNAME --registry $APPNAME --image "${acrFullName}/${APPNAME}:1.0" .


```


### Create two apps with the acr image


```bash

CHARTNAME="secretapp"

mkdir -p $CHARTNAME/templates

cat<<EOF>>$CHARTNAME/Chart.yaml
apiVersion: v2
name: $CHARTNAME
type: application
version: 1.0.0
appVersion: "1.0.0"
EOF


cat<<EOF> $CHARTNAME/values.yaml
application:
  name: $CHARTNAME
image:
  name: $acrFullName/k8ssecrettest:1.0
ports:
  port: 80
  targetPort: 80
EOF


cat<<EOF> $CHARTNAME/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.application.name }}-deployment
spec:
  selector:
    matchLabels:
      app: {{ .Values.application.name }}
  template:
    metadata:
      labels:
        app: {{ .Values.application.name }}
    spec:
      initContainers:
        - name: init-html
          image: busybox
          command:
            - sh
            - -c
            - echo "Welcome to {{ .Values.title }}" > /usr/share/nginx/html/index.html
          volumeMounts:
            - name: html
              mountPath: /usr/share/nginx/html
      containers:
        - name: main-container
          image: {{ .Values.image.name }}
          env:
            - name: SUB_TITLE
              value: {{ .Values.title }}
          volumeMounts:
            - name: html
              mountPath: /usr/share/nginx/html
      imagePullSecrets:
        - name: azure-secret
      volumes: 
        - emptyDir: {}
          name: html
EOF

cat<<EOF> $CHARTNAME/templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.application.name }}
spec:
  type: NodePort
  selector:
    app: {{ .Values.application.name }}
  ports:
    - name: http
      port: {{ .Values.ports.port }}
      targetPort: {{ .Values.ports.targetPort }}
EOF

cat<<EOF> $CHARTNAME/templates/httproute.yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: {{ .Values.application.name }}-httproute
spec:
  parentRefs:
  - name: demoapp-gateway
    namespace: demo-app
  rules:
    - backendRefs:
      - name: {{ .Values.application.name }}
        kind: Service
        port: 80
      matches:
        - path:
            type: PathPrefix
            value: /{{ .Values.postfix }}
      filters:
        - type: URLRewrite
          urlRewrite:
            path:
              type: ReplacePrefixMatch
              replacePrefixMatch: /
EOF


kubectl create secret docker-registry --dry-run=client azure-secret \
  --docker-server=$acrFullName \
  --docker-username=$acrUserName \
  --docker-password=$acrPassword -o yaml > $CHARTNAME/templates/image-pull-secret.yaml



helm install secretapp1 ./$CHARTNAME --set=title=app1 --set=postfix=app1 --namespace secretapp1 --create-namespace
helm install secretapp2 ./$CHARTNAME --set=title=app2 --set=postfix=app2 --namespace secretapp2 --create-namespace


helm uninstall secretapp1 --namespace secretapp1 && kubectl delete namespace secretapp1
helm uninstall secretapp2 --namespace secretapp2 && kubectl delete namespace secretapp2
kubectl delete namespace demo-app

rm -rf $CHARTNAME



```

