```bash

kubectl create namespace debug
kubectl run debug --image nginx --namespace debug

kubectl exec -it debug --namespace debug -- bash

kubectl exec -it debug --namespace debug -- curl test-service.test01:9200

kubectl exec -it debug --namespace debug -- ping 8.8.8.8


```