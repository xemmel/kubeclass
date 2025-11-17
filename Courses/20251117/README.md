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
---
apiVersion: v1
kind: Service
metadata:
  name: test-service
spec:
  selector:
    app: webserver
  ports:
    - port: 80
      targetPort: 80

```

```bash

kubectl delete namespace demo01
kubectl create namespace demo01

kubectl apply --filename deployment.yaml

## Scale

kubectl scale deployment webserver-deployment --replicas 15

## View pods and deployment/replicaset

kubectl get all


### Logs all pods
kubectl logs -l app=webserver -f



## debug pod

kubectl create namespace debug && kubectl run --namespace debug debug --image nginx

### Exec into debug pod

kubectl exec -it --namespace debug debug -- bash


### DNS

[ServiceName].[Namespace]
test-service.demo01


### Port-forward

kubectl port-forward services/test-service 7777:80
```