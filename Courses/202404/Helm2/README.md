### Install a Helm Chart

```powershell

helm install helloapp .\HelloChart\  --namespace helmhellotest  --create-namespace

```


### Upgrade a Helm Chart

```powershell

helm upgrade helloapp .\HelloChart\

```

### Uninstall Helm Chart

```powershell

helm uninstall helloapp

```



### Install with param files

```

helm install hellotestapp .\HelloChart\ --values .\HelloChart\test-values.yaml  --namespace finalhellotest  --create-namespace


helm install helloprodapp .\HelloChart\ --values .\HelloChart\prod-values.yaml  --namespace finalhelloprod  --create-namespace


http://localhost/helmprod

http://localhost/helmtest

```