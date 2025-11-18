### Install Helm

```powershell

winget install Helm.Helm

```

### Commands

```powershell

helm install appx-test appx/ --set "app.name=appx" --set "env=test" --namespace appx-test --create-namespace

helm install appx-prod appx/ --set "app.name=appx" --set "env=prod" --namespace appx-prod --create-namespace

helm upgrade appx-test appx/ --namespace appx-test

helm uninstall appx-test --namespace appx-test



```



