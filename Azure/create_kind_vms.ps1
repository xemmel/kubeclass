### Start master VM


az vm start --resource-group kubeclass-rg --name kubeclass1;

### Shut down master VM

az vm deallocate --resource-group kubeclass-rg --name kubeclass1 --no-wait

### Create snapshot from Master VM

$existingVMResourceId = "/subscriptions/9bc198aa-089c-4698-a7ef-8af058b48d90/resourceGroups/KUBECLASS-RG/providers/Microsoft.Compute/disks/kubeclass1_OsDisk_1_5bc00205a0874919b792bbe1fa747c75";


$newSnapShotJson = az snapshot create `
	--resource-group kubeclass-rg `
	--name thekubesnapshot01 `
	--location germanywestcentral `
	--source $existingVMResourceId
;

$newSnapShot = $newSnapShotJson | ConvertFrom-Json;


## New Kube student VM


$snapshotId = "/subscriptions/9bc198aa-089c-4698-a7ef-8af058b48d90/resourceGroups/kubeclass-rg/providers/Microsoft.Compute/snapshots/thekubesnapshot"

$snapshotId = $newSnapShot.id;



$location = "germanywestcentral";
$subnetId = "/subscriptions/9bc198aa-089c-4698-a7ef-8af058b48d90/resourceGroups/kubeclass-rg/providers/Microsoft.Network/virtualNetworks/kubeclass1-vnet/subnets/default";


$diskSku = "StandardSSD_LRS";
$diskSize = 127;

$vmSize = "Standard_D4ds_v4";


$rgName = "kubeclass-student5-rg";
$vmName = "kubeclass-student5";

az group create --name $rgName --location $location;

az disk create --resource-group $rgName --name $vmName --sku $diskSku --size-gb $diskSize --source $snapshotId


az vm create `
	--name $vmName `
	--resource-group $rgName `
	--os-type windows `
	--attach-os-disk $vmName `
	--location $location `
	--subnet $subnetId `
	--size $vmSize
;
