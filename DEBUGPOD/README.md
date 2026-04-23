## Debug pod


```bash

kubectl create namespace debug && kubectl run --namespace debug debug --image nginx

kubectl exec -it --namespace debug debug -- bash


```