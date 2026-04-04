## Container Apps

### Init

```powershell

$subscriptionId = "bf53a50b-85e5-474d-b261-c87c0ed65901"; ## Customers
$webAppName = "apifaults";
$rgName = "rg-${webAppName}";
$location = "germanywestcentral";

```

### Init linux

```bash

subscriptionId="bf53a50b-85e5-474d-b261-c87c0ed65901"; ## Customers
webAppName="apifaults";
rgName="rg-${webAppName}";
location="germanywestcentral";

```

### Create Resource Group

```powershell

az group create --name $rgName --location $location --subscription $subscriptionId;


```

### Deploy to Azure (Web App)

> Not used

```powershell

Write-Host("Removing existing published files");

if (Test-Path .\publish\) {
    Get-Item .\publish\ | Remove-Item -Recurse -Force
}

if (Test-Path .\publish.zip) {
    Get-Item .\publish.zip | Remove-Item -Recurse -Force
}


Write-Host("Build/Publish .NET code");

dotnet publish -c Release -o ./publish

Write-Host("Zip..");

cd .\publish
Compress-Archive -Force -Path * -DestinationPath ..\publish.zip
cd ..

 az webapp deploy `
        --resource-group $rgName `
        --name $webAppName `
        --src-path ./publish.zip `
        --subscription $subscriptionId
;

if (Test-Path .\publish\) {
    Get-Item .\publish\ | Remove-Item -Recurse -Force
}

if (Test-Path .\publish.zip) {
    Get-Item .\publish.zip | Remove-Item -Recurse -Force
}

```


### Create ACR and Container App Env

```powershell



$acrJson = az acr create `
  --name "acr${webAppName}" `
  --resource-group $rgName `
  --subscription $subscriptionId `
  --sku Basic `
  --admin-enabled true
;

$acr = $acrJson | ConvertFrom-Json;

#### Get admin credentials  (Not needed)
$acrCredentialsJson = az acr credential show `
  --name "acr${webAppName}" `
  --resource-group $rgName `
  --subscription $subscriptionId `
  --location $location
;

$acrCredentials = $acrCredentialsJson | ConvertFrom-Json;


### Container App Env

$containerAppEnvJson = az containerapp env create `
    --name "conenv-${webAppName}" `
    --resource-group $rgName `
    --subscription $subscriptionId `
    --location $location

$containerAppEnv = $containerAppEnvJson | ConvertFrom-Json;


```


### Build and push images to ACR (SOAP)

```powershell

$imageVersion = "1.5";

cd .\SoapFault.Api\

az acr build `
  --registry "$($acr.name)" `
  --subscription $subscriptionId `
  --image "$($acr.name).azurecr.io/soapfault.api:${imageVersion}" .

### Create ContainerApp with image
$containerAppSoapJson = az containerapp create `
  --name "app-soap-${webAppName}" `
  --environment "$($containerAppEnv.name)" `
  --resource-group $rgName `
  --subscription $subscriptionId `
  --registry-server "$($acr.name).azurecr.io" `
  --image "$($acr.name).azurecr.io/soapfault.api:${imageVersion}" `
  --target-port 8080 `
  --ingress 'external'

$containerAppSoap = $containerAppSoapJson | ConvertFrom-Json;



$errorBody = @"
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    <soap:Body>
       <Process xmlns="http://tempuri.org/">
           <input>error</input>
       </Process>	
    </soap:Body>
</soap:Envelope>
"@;



$sw = [System.Diagnostics.Stopwatch]::StartNew()

curl "https://$($containerAppSoap.properties.configuration.ingress.fqdn)/Service.asmx" -X POST -d $errorBody -H "SoapAction: http://tempuri.org/IServiceContract/Process"

$sw.Stop()
$sw.Elapsed.TotalMilliseconds

```

### Build and push images to ACR (REST)

```powershell

cd -
cd .\SoapFault.Rest\

$imageVersion = "1.5";

az acr build `
  --registry "$($acr.name)" `
  --subscription $subscriptionId `
  --image "$($acr.name).azurecr.io/restfault.api:${imageVersion}" .

### Create ContainerApp with image
$containerAppRestJson = az containerapp create `
  --name "app-rest-${webAppName}" `
  --environment "$($containerAppEnv.name)" `
  --resource-group $rgName `
  --subscription $subscriptionId `
  --registry-server "$($acr.name).azurecr.io" `
  --image "$($acr.name).azurecr.io/restfault.api:${imageVersion}" `
  --target-port 80 `
  --ingress 'external'

$containerAppRest = $containerAppRestJson | ConvertFrom-Json;




curl "https://$($containerAppRest.properties.configuration.ingress.fqdn)/version" -X GET 
curl "https://$($containerAppRest.properties.configuration.ingress.fqdn)/test/morten" -X GET 
curl "https://$($containerAppRest.properties.configuration.ingress.fqdn)/test/error" -X GET -v




```

### Build a debug ContainerApp

```powershell

$containerAppDebugJson = az containerapp create `
  --name "app-debug-${webAppName}" `
  --environment "$($containerAppEnv.name)" `
  --resource-group $rgName `
  --subscription $subscriptionId `
  --image "nginx" `
  --target-port 80 `
  --ingress 'internal'

$containerAppDebug = $containerAppDebugJson | ConvertFrom-Json


```

### Build and Push to ACR

```powershell

$imageVersion = "1.5";

### Soap
cd .\SoapFault.Api\

az acr build `
  --registry "$($acr.name)" `
  --subscription $subscriptionId `
  --image "$($acr.name).azurecr.io/soapfault.api:${imageVersion}" .

az containerapp update `
  --name "app-${webAppName}" `
  --resource-group $rgName `
  --subscription $subscriptionId `
  --image "$($acr.name).azurecr.io/soapfault.api:${imageVersion}"

  ### Rest

  cd .\SoapFault.Rest\

az acr build `
  --registry "$($acr.name)" `
  --subscription $subscriptionId `
  --image "$($acr.name).azurecr.io/restfault.api:${imageVersion}" .

az containerapp update `
  --name "app-rest-${webAppName}" `
  --resource-group $rgName `
  --subscription $subscriptionId `
  --image "$($acr.name).azurecr.io/restfault.api:${imageVersion}"



```

### Get Awake status

```powershell


$containerAppType = "Soap";
$result = az containerapp replica count --name $containerAppSoap.name --resource-group $rgName --subscription $subscriptionId;
Write-Host ("${containerAppType}: $result");


$containerAppType = "Rest";
$result = az containerapp replica count --name $containerAppRest.name --resource-group $rgName --subscription $subscriptionId;
Write-Host ("${containerAppType}: $result");


$containerAppType = "Debug";
$result = az containerapp replica count --name $containerAppDebug.name --resource-group $rgName --subscription $subscriptionId;
Write-Host ("${containerAppType}: $result");


```


### Wake them all

```powershell

$sw = [System.Diagnostics.Stopwatch]::StartNew()

### Soap

$errorBody = @"
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    <soap:Body>
       <Process xmlns="http://tempuri.org/">
           <input>error</input>
       </Process>	
    </soap:Body>
</soap:Envelope>
"@;


$jobSoap = Start-Job {curl "https://$($using:containerAppSoap.properties.configuration.ingress.fqdn)/Service.asmx" -X POST -s -d $using:errorBody -H "SoapAction: http://tempuri.org/IServiceContract/Process" 2>&1}

### Rest

$jobRest = Start-Job {curl "https://$($using:containerAppRest.properties.configuration.ingress.fqdn)/test/morten" -s -X GET 2>&1}

## DEbug

$jobDebug = Start-Job {curl "https://$($using:containerAppDebug.properties.configuration.ingress.fqdn)" -s 2>&1}


Wait-Job $jobSoap, $jobRest, $jobDebug

$sw.Stop()
$sw.Elapsed.TotalMilliseconds

Receive-Job $jobSoap
Receive-Job $jobRest
Receive-Job $jobDebug

Get-Job

Get-Job | Remove-Job -Force



```

### Exec into debug ACA

```powershell

az containerapp exec `
  --name "app-debug-${webAppName}" `
  --resource-group $rgName `
  --subscription $subscriptionId `
  --command "/bin/sh"

az containerapp exec `
  --name "app-debug-${webAppName}" `
  --resource-group $rgName `
  --subscription $subscriptionId `
  --command "bash"

```

### Get existing ACR

```powershell

$acrJson = az acr show `
  --name "acr${webAppName}" `
  --resource-group $rgName `
  --subscription $subscriptionId
;

$acr = $acrJson | ConvertFrom-Json;

```


### Get existing ContainerApp Env

```powershell

$containerAppEnvJson = az containerapp env show `
    --name "conenv-${webAppName}" `
    --resource-group $rgName `
    --subscription $subscriptionId

$containerAppEnv = $containerAppEnvJson | ConvertFrom-Json;

```

### Get existing ContainerApps

```powershell

#### Debug

$containerAppDebugJson = az containerapp show `
  --name "app-debug-${webAppName}" `
  --resource-group $rgName `
  --subscription $subscriptionId

$containerAppDebug = $containerAppDebugJson | ConvertFrom-Json


#### Soap

$containerAppSoapJson = az containerapp show `
  --name "app-soap-${webAppName}" `
  --resource-group $rgName `
  --subscription $subscriptionId

$containerAppSoap = $containerAppSoapJson | ConvertFrom-Json


#### Rest

$containerAppRestJson = az containerapp show `
  --name "app-rest-${webAppName}" `
  --resource-group $rgName `
  --subscription $subscriptionId

$containerAppRest = $containerAppRestJson | ConvertFrom-Json

```

### Calls 

```powershell

$errorBody = @"
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    <soap:Body>
       <Process xmlns="http://tempuri.org/">
           <input>error</input>
       </Process>	
    </soap:Body>
</soap:Envelope>
"@;


curl "https://$($containerAppSoap.properties.configuration.ingress.fqdn)/Service.asmx" -X POST -d $errorBody -H "SoapAction: http://tempuri.org/IServiceContract/Process"



curl "https://$($containerAppRest.properties.configuration.ingress.fqdn)/version" -X GET
curl "https://$($containerAppRest.properties.configuration.ingress.fqdn)/test/morten" -X GET
curl "https://$($containerAppRest.properties.configuration.ingress.fqdn)/test/error" -X GET -v




```

### Cleanup

```powershell

az group delete --name $rgName --subscription $subscriptionId --yes


```