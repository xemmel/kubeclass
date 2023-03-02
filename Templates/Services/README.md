### Apply Service

```powershell

kubectl apply -f .\service.yaml

```

### Describe service

```powershell

kubectl describe service demo2-service

```

### Enter debug pod

```powershell

kubectl exec -it pod -n debug -- bash

```

### Call Service in Debug Pod

```powershell

curl demo2-service.demo2

```