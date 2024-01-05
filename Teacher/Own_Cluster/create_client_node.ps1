Clear-Host;
$number = Read-Host("number");
$vmName = "kube-client-$($number)";
Write-Host("Creating client node server: $($vmName)");
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
    --subnet $subnetClient.Id 
   ;
$vmclient01 = $vmJson | ConvertFrom-Json;
$vmclient01.publicIpAddress;

$vmclient01.publicIpAddress | Set-Clipboard;
