## Full Pyhton/Kubernetes

```bash

sudo iptables -P FORWARD ACCEPT

multipass launch --name kubserver --cpus 2 --memory 4G --disk 20G

multipass shell kubserver

------------

sudo apt update && sudo apt upgrade -y
sudo apt install python3 python3-pip python3-venv -y

mkdir code
cd code

python3 -m venv devenv
source devenv/bin/activate

pip install "fastapi[standard]"

mkdir app
cd app

cat<<EOF>>app.py
from fastapi import FastAPI

app = FastAPI()

@app.get("/version")
def get_version():
  return { "version" : "1.0" }
EOF

fastapi dev app.py

## Other terminal

curl localhost:8000/version

## Docker

sudo apt install docker.io -y
sudo usermod -aG docker $USER
newgrp docker

cat<<EOF>>requirements.txt
fastapi[standard]>=0.113.0,<0.114.0
pydantic>=2.7.0,<3.0.0
EOF

cat<<EOF>>Dockerfile
FROM python:latest

WORKDIR /code

COPY ./requirements.txt /code/requirements.txt

RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

COPY ./app.py /code/app/app.py

CMD ["fastapi", "run", "app/app.py", "--port", "80"]
EOF

docker build -t webapi:1.0 .


### docker run
docker run -it --name webapi1 --publish 8888:80 -d webapi:1.0

curl localhost:8888/version

docker ps -a -q | xargs docker rm -f


### Kubernetes

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

chmod +x kubectl
mkdir -p ~/.local/bin
mv ./kubectl ~/.local/bin/kubectl

### kubectl completion

sudo apt-get install -y bash-completion
echo "source <(kubectl completion bash)" >> ~/.bashrc
source ~/.bashrc


curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.31.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

kind create cluster --name mycluster



kubectl create namespace test
kubectl config set-context --current --namespace test

kind load docker-image webapi:1.0 --name mycluster

cd ..
cd ..
mkdir templates
cd templates

cat<<EOF>>deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deployment
spec:
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
        - name: api-container
          image: webapi:1.0
---
apiVersion: v1
kind: Service
metadata:
  name: api-service
spec:
  selector:
    app: api
  ports:
    - port: 80
      targetPort: 80
EOF

kubectl apply --filename deployment.yaml


### Debug

kubectl create namespace debug && kubectl run debug --namespace debug --image nginx

kubectl exec -it --namespace debug debug -- bash

curl api-service.test/version


```