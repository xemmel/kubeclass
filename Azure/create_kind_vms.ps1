### Start master VM


az vm start --resource-group kubeclass-rg --name kubeclass1;

### Shut down master VM

az vm deallocate --resource-group kubeclass-rg --name kubeclass1 --no-wait

### Create snapshot from Master VM

$existingVMResourceId = "/subscriptions/9bc198aa-089c-4698-a7ef-8af058b48d90/resourceGroups/KUBECLASS-RG/providers/Microsoft.Compute/disks/kubeclass1_OsDisk_1_5bc00205a0874919b792bbe1fa747c75";


$newSnapShotJson = az snapshot create `
	--resource-group kubeclass-rg `
	--name thekubesnapshot03 `
	--location germanywestcentral `
	--subscription 9bc198aa-089c-4698-a7ef-8af058b48d90 `
	--source $existingVMResourceId
;

$newSnapShot = $newSnapShotJson | ConvertFrom-Json;

### Create a NSG Rule

$myIp = (Invoke-WebRequest ifconfig.me/ip).Content.Trim();

az network nsg rule create `
	--name studentIps `
	--nsg-name kubeclass1-nsg `
	--resource-group kubeclass-rg `
	--priority 1001 `
	--access Allow `
	--direction Inbound `
	--protocol * `
	--source-address-prefixes $myIp `
	--source-port-ranges * `
	--destination-port-ranges 3389 `
	--subscription 9bc198aa-089c-4698-a7ef-8af058b48d90
;

### Remove NSG Rule

az network nsg rule delete `
	--name studentIps `
	--nsg-name kubeclass1-nsg `
	--resource-group kubeclass-rg `
	--subscription 9bc198aa-089c-4698-a7ef-8af058b48d90
;

#### Start vm



## New Kube student VM


$snapshotId = "/subscriptions/9bc198aa-089c-4698-a7ef-8af058b48d90/resourceGroups/kubeclass-rg/providers/Microsoft.Compute/snapshots/thekubesnapshot03"

$snapshotId = $newSnapShot.id;



$location = "germanywestcentral";
$subnetId = "/subscriptions/9bc198aa-089c-4698-a7ef-8af058b48d90/resourceGroups/kubeclass-rg/providers/Microsoft.Network/virtualNetworks/kubeclass1-vnet/subnets/default";


$diskSku = "StandardSSD_LRS";
$diskSize = 127;

$vmSize = "Standard_D4ds_v4";

$studentNo = Read-Host("Student no");
$rgName = "kubeclass-student${studentNo}-rg";
$vmName = "kubeclass-student${studentNo}";

az group create --name $rgName --location $location --subscription 9bc198aa-089c-4698-a7ef-8af058b48d90;

az disk create --resource-group $rgName --name $vmName --sku $diskSku `
	--size-gb $diskSize --source $snapshotId `
	--subscription 9bc198aa-089c-4698-a7ef-8af058b48d90
;


az vm create `
	--name $vmName `
	--resource-group $rgName `
	--os-type windows `
	--attach-os-disk $vmName `
	--location $location `
	--subnet $subnetId `
	--size $vmSize `
	--subscription 9bc198aa-089c-4698-a7ef-8af058b48d90
;
