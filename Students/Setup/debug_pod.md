## Setup debug pod


### setup

```bash

kubectl create namespace debug
kubectl run debug --image nginx --namespace debug

```

### usage

```bash

### bash into debug pod

kubectl exec -it debug --namespace debug -- bash

### run command from outside

kubectl exec -it debug --namespace debug -- curl https://tv2.dk

### ping install

kubectl exec -it debug --namespace debug -- apt-get update -y
kubectl exec -it debug --namespace debug -- apt-get install -y iputils-ping


### ping
kubectl exec -it debug --namespace debug -- ping 8.8.8.8



```