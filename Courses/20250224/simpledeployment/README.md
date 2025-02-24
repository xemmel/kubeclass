```powershell

kubectl create namespace test03

kubectl config set-context --current --namespace test03

kubectl apply --filename hellodeployment.yaml

kubectl describe service **servicename**

### In debug pod

curl servicename.namespacename

```


#### Port forward (Service)

```powershell

kubectl port-forward service/**serviceName** 4444:80


```