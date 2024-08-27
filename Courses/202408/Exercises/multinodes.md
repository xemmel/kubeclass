
\kubeclass\Courses\202408>

```powershell

kubectl create namespace day2

kubectl config set-context --current --namespace day2

kubectl apply --filename .\templates\multideployment.yaml


### Check pods on nodes

kubectl get pods -o wide

```


## No new pods on node

```powershell

kubectl cordon multinodes-worker3

```

### Drain all pods from node

```powershell

kubectl drain --ignore-daemonsets --force multinodes-worker3

```