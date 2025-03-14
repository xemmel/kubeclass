#### Debug

```bash
kubectl create namespace debug
kubectl run debug --image nginx --namespace debug

kubectl exec -it debug --namespace debug -- bash


```