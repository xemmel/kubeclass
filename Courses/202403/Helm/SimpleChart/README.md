## Install

```powershell

helm install helmdemo2 .\SimpleChart\ --namespace helmdemo3 --create-namespace

```

## Upgrade 

```powershell

helm upgrade helmdemo2 .\SimpleChart\

```


### Install/Upgrade with mixed values


```powershell

helm upgrade helloprod .\SimpleChart\  --set "app.title=prod title" --values .\SimpleChart\values-prod.yaml --namespace helloprod

```