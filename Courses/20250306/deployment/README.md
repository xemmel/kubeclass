```powershell

kubectl delete namespace test01
kubectl create namespace test02
kubectl config set-context --current --namespace test02
kubectl apply --filename deployment.yaml


kubectl scale deployment hello-deployment --replicas 2




```