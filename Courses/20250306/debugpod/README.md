#### Debug

```bash
kubectl create namespace andersand
kubectl run mickey --image nginx --namespace andersand

kubectl exec -it mickey --namespace andersand -- bash


```