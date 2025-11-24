
### Cleanup

```bash

kubectl delete --filename pod.yaml

kubectl delete namespace demo01
kubectl create namespace demo01


```

### Deploy deployment

```bash

kubectl apply --filename deployment.yaml

kubectl get all


```


### Scale deployment


```bash

kubectl scale deployment webserver-deployment --replicas 8

```