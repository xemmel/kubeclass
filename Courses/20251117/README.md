## 2025 - 11 - 17




### Your first Deployment

> name it *deployment.yaml*

```yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: webserver-deployment
spec:
  selector:
    matchLabels:
      app: webserver
  template:
    metadata:
      labels:
        app: webserver
    spec:
      containers:
        - image: nginx
          name: webserver-container

```

```bash

kubectl delete namespace demo01
kubectl create namespace demo01

kubectl apply --filename deployment.yaml

## Scale

kubectl scale deployment webserver-deployment --replicas 15

## View pods and deployment/replicaset

kubectl get all


```