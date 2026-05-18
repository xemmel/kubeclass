# 2026-05-18

## Installation

### In powershell

```powershell

winget install Microsoft.WindowsTerminal

winget install Canonical.Multipass

winget install Microsoft.VisualStudioCode

```

### Launch kindserver

```powershell

multipass launch --name kindserver --memory 4GB --cpus 2 --disk 20GB devel

multipass shell kindserver

```

### Install docker 

```bash

sudo apt install docker-buildx -y
sudo usermod -aG docker $USER
newgrp docker


docker images

```


### install kubectl

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

### install kind

```bash

curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.31.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind


```

### Create cluster

```bash

kind create cluster

kubectl get namespaces

```

### Create deployment

```bash

kubectl create namespace test01

kubectl config set-context --current --namespace test01

cat<<EOF>>deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-deployment
spec:
  selector:
    matchLabels:
      app: testapp
  template:
    metadata:
      labels:
        app: testapp
    spec:
      containers:
       - name: maincontainer
         image: nginx
---
apiVersion: v1
kind: Service
metadata:
  name: testapp
spec:
  selector:
    app: testapp
  ports:
    - name: http
      port: 80
      targetPort: 80
EOF

## apply deployment and service
kubectl apply --filename deployment.yaml

## view all (pods, services)
kubectl get all

## view pods with ip-addresses
kubectl get pods -o wide

## Scale
kubectl scale deployment test-deployment --replicas 3


### debug pod
kubectl create namespace debug
kubectl run --namespace debug debug --image nginx

kubectl exec -it --namespace debug debug -- bash


### Call service dns
curl testapp.test01

```