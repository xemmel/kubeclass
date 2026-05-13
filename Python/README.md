## Python

### Raw walkthrough
```bash

sudo iptables -P FORWARD ACCEPT

multipass launch --name pytdev --disk 30G --memory 4G --cpus 2

multipass shell pytdev


sudo apt update && sudo apt upgrade -y

sudo apt install python3-pip python3-venv -y

mkdir code

cd code

python3 -m venv devenv

source ./devenv/bin/activate

pip install fastapi[standard]


mkdir api1

cd api1





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


## fastapi dev

uvicorn app:app --port 8000 --no-access-log &

## Press enter

curl localhost:8000/items/123

fg


### Docker

sudo apt install docker.io -y
sudo usermod -aG docker $USER
newgrp docker


## New better
sudo apt install docker-buildx -y
sudo usermod -aG docker $USER
newgrp docker


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

IMAGENAME="api1:1.1"

docker buildx build --tag $IMAGENAME .

docker run --name api1 --publish 8899:80 -d $IMAGENAME

curl localhost:8899/items/125


docker ps -f name=api1 -q | xargs docker rm -f



exit

exit


multipass delete pytdev --purge

```


### Push local docker images into k8s worker nodes

```bash

VERSION="1.2"
IMAGENAME="api1:${VERSION}"
IMAGESAVENAME="api1-${VERSION}"



docker save $IMAGENAME -o $IMAGESAVENAME.tar

multipass transfer $IMAGESAVENAME.tar worker1-flowgrait-k8s:/home/ubuntu/$IMAGESAVENAME.tar

## multipass shell worker1-flowgrait-k8s

### Takes a while

multipass exec worker1-flowgrait-k8s -- sudo ctr -n k8s.io images import /home/ubuntu/$IMAGESAVENAME.tar


multipass exec worker1-flowgrait-k8s -- sudo ctr -n k8s.io images ls | grep -i api

multipass exec worker1-flowgrait-k8s -- sudo rm /home/ubuntu/$IMAGESAVENAME.tar

rm $IMAGESAVENAME.tar





```

### Test own image

```bash
NS="ownimage"
kubectl create namespace $NS


kubectl apply --namespace $NS -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ownimage-deployment
spec:
  selector:
    matchLabels:
      app: ownimage
  template:
    metadata:
      labels:
        app: ownimage
    spec:
      containers:
        - name: ownimage-container
          image: $IMAGENAME
---
apiVersion: v1
kind: Service
metadata:
  name: ownimage
spec:
  type: NodePort
  selector:
    app: ownimage
  ports:
    - name: http
      port: 80
      targetPort: 80
EOF


WORKER_NODE_IP=$(kubectl get nodes -o wide | grep worker | awk ' {print $6}')
OWN_NODE_PORT=$(kubectl get services -A | grep -i ownimage | awk '{ print $6 }' | awk -F":" '{ print $2 }' | awk -F"/" '{ print $1 }')

curl "http://${WORKER_NODE_IP}:${OWN_NODE_PORT}/items/345"


```

