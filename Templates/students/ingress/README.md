### Install ingress cluster

```powershell

### Templates/students/ingress>

kind create cluster `
    --name ingresscluster `
    --config .\cluster.yaml
;

```

### Install INGRESS CONTROLLER

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

IP_ADDRESS=$(docker container inspect ingresscluster-control-plane \
  --format '{{ .NetworkSettings.Networks.kind.IPAddress }}')

echo $IP_ADDRESS



```

### Standard on ubuntu

```

/var/lib/docker/volumes/....id.../_data/local-path-provisioner

```