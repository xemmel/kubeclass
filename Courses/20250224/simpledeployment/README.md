```powershell

kubectl create namespace test03

kubectl config set-context --current --namespace test03

kubectl apply --filename simpledeployment.yaml

```