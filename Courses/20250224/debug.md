```powershell

kubectl create namespace debug
kubectl run debug --image nginx --namespace debug

kubectl exec -it debug --namespace debug -- bash

kubectl exec -it debug --namespace debug -- ping 8.8.8.8

kubectl exec -it debug --namespace debug -- curl 10.96.28.94:9200


### Service dns

curl serviceName.[namespaceName]
```