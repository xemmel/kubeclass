Clear-Host;

$appName = "intitkube";
$location = "swedencentral";
$vnetAddressCore = "10.57";
$rgName = "$($appName)-rg";


$image = "Ubuntu2204";
$userName = "kubeadmin";
$size = "Standard_D2_v4";
$diskSize = 64;
$password = Read-Host("password");
