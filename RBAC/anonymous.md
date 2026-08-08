## Ano

```bash

kubectl create clusterrole list-all-namespaces --verb=get,list --resource=namespaces

kubectl create clusterrolebinding list-all-namespaces-anonymous \
  --clusterrole=list-all-namespaces --user=system:anonymous


kubectl delete clusterrolebinding list-all-namespaces-anonymous
kubectl delete clusterrole list-all-namespaces


```