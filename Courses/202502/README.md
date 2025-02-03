## Feb. 2025


### Create debug pod 
```powershell

kubectl create namespace debugpod

kubectl run debugpod --image nginx --namespace debugpod

```

### Use Debug pod

```powershell

kubectl exec -it debugpod --namespace debugpod -- bash

```

### Curl service other namespace

```powershell

curl [serviceName].[nameSpaceName]

```
