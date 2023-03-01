## Build image

```powershell

docker build -t myown:1.0 .

```

### Apply the deployment

> This will not work since the kubernetes cluster cannot
> find the image *myown:1.0*

```powershell

kubectl apply -f .\Apps\Own\deployment.yaml

```

### Load the image from local **Docker** into *Kubernetes* cluster

> Cluster name may vary
> 
```powershell
kind load docker-image myown:1.0 --name the2cluster;
```

