Clear-Host;
$number = Read-Host("number");
$vmName = "kube-worker-$($number)";
Write-Host("Creating Worker node server: $($vmName)");
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
    --subnet $subnetWorker.Id 
   ;
$vmWorker01 = $vmJson | ConvertFrom-Json;
$vmWorker01.publicIpAddress;

$vmWorker01.publicIpAddress | Set-Clipboard;
