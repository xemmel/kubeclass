
\kubeclass\Courses\202408>

```powershell

kubectl create namespace day2

kubectl config set-context --current --namespace day2

kubectl apply --filename .\templates\multideployment.yaml


### Check pods on nodes

kubectl get pods -o wide

```