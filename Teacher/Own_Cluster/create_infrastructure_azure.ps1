Clear-Host;
### Resource Group
Write-Host("Creating Resource Group: $($rgName)");
$rg = New-AzResourceGroup -ResourceGroupName $rgName -Location $location;


### NSGS

$myIP = (Invoke-WebRequest -uri "https://api.ipify.org/").Content;
Write-Host("Creating nsg's with your ip allowed: $($myIP)");
## Create node NSG


Write-Host("Creating node NSG...");


$ips = $myIP.Split('.')
$ipRange = "$($ips[0]).$($ips[1]).0.0/16";
$ipRange = $myIP; ## Remove for broader
$ruleMasterHomeSSHInbound = New-AzNetworkSecurityRuleConfig `
    -Direction Inbound `
    -Name "uncleMortenHomeSSH" `
    -Priority 1000 `
    -SourceAddressPrefix $ipRange `
    -SourcePortRange * `
    -Protocol Tcp `
    -Access Allow `
    -DestinationPortRange 22 `
    -DestinationAddressPrefix *
;

$ruleMasterHomeClusterInbound = New-AzNetworkSecurityRuleConfig `
    -Direction Inbound `
    -Name "uncleMortenHomeClusterAPI" `
    -Priority 1010 `
    -SourceAddressPrefix $ipRange `
    -SourcePortRange * `
    -Protocol Tcp `
    -Access Allow `
    -DestinationPortRange 16443 `
    -DestinationAddressPrefix *
;

$nodeNsg = New-AzNetworkSecurityGroup `
        -ResourceGroupName $rg.ResourceGroupName `
        -Name "nsg-node-$appName" `
        -Location $rg.Location `
        -SecurityRules $ruleMasterHomeSSHInbound, $ruleMasterHomeClusterInbound
;


## Create client NSG
Write-Host("Creating client NSG...");

$ruleMasterHomeRDPInbound = New-AzNetworkSecurityRuleConfig `
    -Direction Inbound `
    -Name "uncleMortenHomeRDP" `
    -Priority 1001 `
    -SourceAddressPrefix $ipRange `
    -SourcePortRange * `
    -Protocol Tcp `
    -Access Allow `
    -DestinationPortRange 3389 `
    -DestinationAddressPrefix *
;

$clientNsg = New-AzNetworkSecurityGroup `
        -ResourceGroupName $rg.ResourceGroupName `
        -Name "nsg-client-$appName" `
        -Location $rg.Location `
        -SecurityRules $ruleMasterHomeRDPInbound
;

### END NSG

### VNET

## VNET
Write-Host("Creating Virtual Network");
$vnet = New-AzVirtualNetwork `
        -Name "vnet-$appName" `
        -ResourceGroupName $rg.ResourceGroupName `
        -Location $rg.Location `
        -AddressPrefix "$($vnetAddressCore).0.0/16"
;



## Subnet master
Write-Host("Creating Subnet master");

$subnetMasterJson = az network vnet subnet create `
    --name "master" `
    --resource-group $rg.ResourceGroupName `
    --vnet-name $vnet.Name `
    --address-prefixes "$($vnetAddressCore).10.0/24" `
    --nsg $nodeNsg.Id
;
$subnetMaster = $subnetMasterJson | ConvertFrom-Json;

## Subnet worker

Write-Host("Creating Subnet worker");
$subnetWorkerJson = az network vnet subnet create `
    --name "worker" `
    --resource-group $rg.ResourceGroupName `
    --vnet-name $vnet.Name `
    --address-prefixes "$($vnetAddressCore).11.0/24" `
    --nsg $nodeNsg.Id
;
$subnetWorker = $subnetWorkerJson | ConvertFrom-Json;

## Subnet clients
Write-Host("Creating Subnet clients");
$subnetClientJson = az network vnet subnet create `
    --name "client" `
    --resource-group $rg.ResourceGroupName `
    --vnet-name $vnet.Name `
    --address-prefixes "$($vnetAddressCore).12.0/24" `
    --nsg $clientNsg.Id
;
$subnetClient = $subnetClientJson | ConvertFrom-Json;



### END VNET