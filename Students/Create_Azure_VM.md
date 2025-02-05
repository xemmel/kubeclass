### Create VM

```powershell

$appName = "studentkubevm";
$clientIp = (curl ifconfig.me)
$password = Read-Host("password");
$location = "germanywestcentral";

az group create --name "rg-${appName}" --location $location;

$result = az deployment group create `
    --resource-group "rg-${appName}" `
    --template-file .\full_azure_vm.bicep `
    --parameters appName=$appName `
    --parameters clientIp=$clientIp `
    --parameters password=$password
;

$ip = $result | ConvertFrom-Json | Select-Object -ExpandProperty properties | Select-Object -ExpandProperty outputs | Select-Object -ExpandProperty ip | Select-Object -ExpandProperty value

Write-Host("Public IP: ${ip}");
mstsc /v:$ip



### Clean up
az group delete --name "rg-${appName}" --no-wait --yes

### Check
az resource list --resource-group "rg-${appName}" --output table


```