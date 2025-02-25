### install chart


```powershell

helm install app .\app\  --namespace app-test --create-namespace

```

### Update chart

```powershell

helm upgrade app .\app\

```

### delete chart

```powershell

helm uninstall app

```

### install with params

```powershell

helm install appprod .\app\ --set appname=prodapp  --namespace app-prod --create-namespace

```

### upgrade with params

```powershell

helm upgrade apptest .\app\ --set appname=testapp

```

### With default values

```powershell

helm install appptest .\app\ --set appname=testapp  --namespace app-test --create-namespace
helm install apppprod .\app\ --set appname=prodapp --set replicas=6  --namespace app-prod --create-namespace


```