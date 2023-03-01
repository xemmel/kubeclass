## 

```powershell

$clusterName = "the2cluster";
$image = "mcr.microsoft.com/azuredocs/aks-helloworld:v1";

docker pull $image;

kind load docker-image $image --name $clusterName;

$namespace = "firstdemo";

kubectl create namespace $namespace;

kubectl create deployment $namespace-deployment `
    --image $image `
    --dry-run=client -o yaml `
    --namespace $namespace | 
    Set-Clipboard
;

```