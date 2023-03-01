## Deploy

```powershell

kubectl apply -f .\Templates\Debug\curlpod.yaml

```

### Use

```powershell

kubectl exec -it pod -n debug -- bash

```

