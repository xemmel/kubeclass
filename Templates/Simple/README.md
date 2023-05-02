```powershell

kubectl apply -f .\Templates\deployment.yaml


kubectl delete -f .\Templates\deployment.yaml



### Expose Internal Service

kubectl port-forward service/myservice 4444:80

```