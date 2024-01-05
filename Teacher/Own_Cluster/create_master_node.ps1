Clear-Host;

$number = Read-Host("number");
$vmName = "kube-master-$($number)";
Write-Host("Creating Master node server: $($vmName)");
$vmJson = az vm create `
    --resource-group $rg.ResourceGroupName `
    --name $vmName `
    --image $image `
    --admin-username $userName `
    --admin-password $password `
    --location $location `
    --size $size `
    --os-disk-size-gb $diskSize `
    --public-ip-sku Standard `
    --generate-ssh-keys `
    --assign-identity [system] `
    --nsg '""' `
    --subnet $subnetMaster.Id 
   ;
$vmMaster01 = $vmJson | ConvertFrom-Json;
$vmMaster01.publicIpAddress;
$vmMaster01.publicIpAddress | Set-Clipboard;