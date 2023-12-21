```powershell

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

```


```powershell

kubectl wait --namespace ingress-nginx `
  --for=condition=ready pod `
  --selector=app.kubernetes.io/component=controller `
  --timeout=90s
```

### On ubuntu??? Get IP


```powershell

IP_ADDRESS=$(docker container inspect ingress-control-plane \
  --format '{{ .NetworkSettings.Networks.kind.IPAddress }}')

echo $IP_ADDRESS



```