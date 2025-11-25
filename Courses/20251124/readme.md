
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


### Services

```bash

kubectl describe service webserver-service

```


### Debug pod

```bash

kubectl create namespace debug && kubectl run debug --namespace debug --image nginx


kubectl exec -it debug --namespace debug -- bash


```

#### Call Service via DNS

```bash

curl webserver-service.demo01

```

#### Port-forward 
> DEV/TEST ONLY!!!!

```bash
kubectl port-forward services/webserverhello-service 5555:80

```

### Rollout restart 

```bash

kubectl rollout restart deployment webserverhello-deployment

```