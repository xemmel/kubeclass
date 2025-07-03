```powershell

$namespace = "demo03";

$namespace = Read-Host("namespace");
kubectl create namespace $namespace;
kubectl config set-context --current --namespace $namespace;

```