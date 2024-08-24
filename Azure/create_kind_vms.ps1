### Start master VM

$subscriptionId = "9bc198aa-089c-4698-a7ef-8af058b48d90"
$rgName = "kubeclass-rg";
;

### view vms
az vm list --subscription $subscriptionId -o table -d
;


az vm start --resource-group kubeclass-rg --name kubeclass1 `
	--subscription $subscriptionId
;

### Shut down master VM

az vm deallocate --resource-group kubeclass-rg --name kubeclass1 `
	--subscription $subscriptionId --no-wait
;

### View Resources
az resource list `
	--resource-group kubeclass-rg --subscription $subscriptionId -o table
;

### View snapshots

az snapshot list --resource-group $rgName --subscription $subscriptionId -o table
;


### Delete snapshots

az snapshot list --resource-group KUBECLASS-RG --subscription $subscriptionId -o json | 
	ConvertFrom-Json | 
	Select-Object name,id | 
	Out-GridView -PassThru | 
	ForEach-Object {az snapshot delete --ids $_.id}
;

### Delete student VM's

az group list --subscription $subscriptionId -o json | 
	ConvertFrom-Json |
	Where-Object {$_.Name -like 'kubeclass-student*'} |
	Out-GridView -PassThru |
	ForEach-Object {az group delete --name $_.Name --subscription $subscriptionId --yes }
;

#### password reminder to Windows Servers

3 capital

EscapeMovie  LastSongOnKuwaitAlbum WhereAmIDanishAbb TwoYearsAfterRYouTube Bang


### Reset password

az vm user update `
	--username kubeadmin `
	--password $password `
	--resource-group kubeclass-rg --name kubeclass1 `
	--subscription $subscriptionId
;

### Create snapshot from Master VM

$existingVMResourceId = "/subscriptions/9bc198aa-089c-4698-a7ef-8af058b48d90/resourceGroups/KUBECLASS-RG/providers/Microsoft.Compute/disks/kubeclass1_OsDisk_1_5bc00205a0874919b792bbe1fa747c75";

$snapShotName = "thekubesnapshot20240824"
$newSnapShotJson = az snapshot create `
	--resource-group $rgName `
	--name $snapShotName `
	--location germanywestcentral `
	--subscription $subscriptionId `
	--source $existingVMResourceId
;

$newSnapShot = $newSnapShotJson | ConvertFrom-Json;

### Create a NSG Rule

$myIp = (Invoke-WebRequest ifconfig.me/ip).Content.Trim();
$myIp = (curl ifconfig.me);


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
	--subscription $subscriptionId
;



#### Linux

$location = "germanywestcentral";
$publisher = "Canonical";
$offer = "0001-com-ubuntu-server-jammy";


$sku = "22_04-lts-gen2";

az vm image list-skus `
	--location $location `
	--offer $offer `
	--publisher $publisher `
	--output table
;

$image = "${publisher}:${offer}:${sku}:latest";
$image = "Ubuntu2204";

$diskSku = "StandardSSD_LRS";
$diskSize = 127;

$vmSize = "Standard_D4ds_v4";
$subnetId = "/subscriptions/9bc198aa-089c-4698-a7ef-8af058b48d90/resourceGroups/kubeclass-rg/providers/Microsoft.Network/virtualNetworks/kubeclass1-vnet/subnets/default";



az vm create `
	--resource-group kubeclass-rg `
	--location $location `
	--name kubernetes-master-linux `
	--image $image `
	--size $vmSize `
	--admin-username kubeadmin `
	--admin-password $password `
	--nsg '""' `
	--subnet $subnetId `
	--os-disk-size-gb $diskSize `
	--storage-sku $diskSku
;


$existingVMResourceId = "/subscriptions/9bc198aa-089c-4698-a7ef-8af058b48d90/resourceGroups/KUBECLASS-RG/providers/Microsoft.Compute/disks/kubernetes-master-linux_disk1_5301b31ac026405baa6bf1ef0b249397";


$newSnapShotJson = az snapshot create `
	--resource-group kubeclass-rg `
	--name thekubelinuxsnapshot01 `
	--location germanywestcentral `
	--subscription 9bc198aa-089c-4698-a7ef-8af058b48d90 `
	--source $existingVMResourceId
;

$newSnapShot = $newSnapShotJson | ConvertFrom-Json;

$snapshotId = $newSnapShot.id;

$snapshotId = "/subscriptions/9bc198aa-089c-4698-a7ef-8af058b48d90/resourceGroups/kubeclass-rg/providers/Microsoft.Compute/snapshots/thekubelinuxsnapshot01";



$location = "germanywestcentral";
$subnetId = "/subscriptions/9bc198aa-089c-4698-a7ef-8af058b48d90/resourceGroups/kubeclass-rg/providers/Microsoft.Network/virtualNetworks/kubeclass1-vnet/subnets/default";


$diskSku = "StandardSSD_LRS";
$diskSize = 127;

$vmSize = "Standard_D4ds_v4";

$studentNo = Read-Host("Student no");
$rgName = "kubeclass-student${studentNo}-rg";
$vmName = "kubeclass-student${studentNo}-linux";

az group create --name $rgName --location $location --subscription 9bc198aa-089c-4698-a7ef-8af058b48d90;

az disk create --resource-group $rgName --name $vmName --sku $diskSku `
	--size-gb $diskSize --source $snapshotId `
	--subscription 9bc198aa-089c-4698-a7ef-8af058b48d90
;


az vm create `
	--name $vmName `
	--resource-group $rgName `
	--os-type linux `
	--attach-os-disk $vmName `
	--location $location `
	--subnet $subnetId `
	--size $vmSize `
	--subscription 9bc198aa-089c-4698-a7ef-8af058b48d90
;
