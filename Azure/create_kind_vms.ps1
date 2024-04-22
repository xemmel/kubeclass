## KUBE DISK


$snapshotId = "/subscriptions/9bc198aa-089c-4698-a7ef-8af058b48d90/resourceGroups/kubeclass-rg/providers/Microsoft.Compute/snapshots/thekubesnapshot"




$location = "germanywestcentral";
$subnetId = "/subscriptions/9bc198aa-089c-4698-a7ef-8af058b48d90/resourceGroups/kubeclass-rg/providers/Microsoft.Network/virtualNetworks/kubeclass1-vnet/subnets/default";


$diskSku = "StandardSSD_LRS";
$diskSize = 127;

$vmSize = "Standard_D4ds_v4";


$rgName = "kubeclass-student4-rg";
$vmName = "kubeclass-student4";

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
