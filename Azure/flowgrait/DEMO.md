## Demo Flowgrait

### Init CLI

```powershell
az account set -s 5a05f537-a707-4bc8-99bc-0ad16de9d511 ##Intit Platformdev
set-azContext -SubscriptionId 5a05f537-a707-4bc8-99bc-0ad16de9d511 ##Intit Platformdev
```

### Init Variables

```powershell
cd C:\code\customers\integrationit\devops\integrationengine\ais

$env = "dev";
. .\documentation\scripts\init.ps1 -env $env;

```

### Set new domain name

```powershell
$domainName = Read-Host("domain");
```

### Create new domain

#### Create branch
```powershell
git checkout master
git pull
git checkout -b "domain_${domainName}"
$branchName = git rev-parse --abbrev-ref HEAD

```

#### Create domain folder and files

```powershell

mkdir .\domains\$domainName

Get-ChildItem .\documentation\documentation\domain\templates | 
Copy-Item -Destination .\domains\$domainName
;

### Replace %DomainName% with $domainName
Get-ChildItem -Path ".\domains\$domainName" -Filter *.yaml | 
    ForEach-Object { 
            (Get-Content $_.FullName -Raw) -replace '%DomainName%', $domainName 
            | Set-Content $_.FullName 
        }
;

git add .

git commit -m "Added domain '${domainName}'"

git push


git push origin $branchName;

```

### Create Pipeline

```powershell
$commonVariableGroupId = "13";
## $groupEnvVariableGroupId = "85"; ## Env Group group-demo
$groupEnvVariableGroupId = "28"; ## Env Group group-dev
$unitTestPipelineId = "73";
$environmentId = "11"; ## env: dev
$flowTemplateRepoId = "d98e3705-c675-487e-b9d5-12d777fa00bd"
$flowTemplateProjectId = "a14659f8-2402-4a0a-a8e5-9d0ef66b1fff";



. .\documentation\scripts\devops\createPipelinev2.ps1 -systemName $domainName -branch $branchName -commonVarGroupId $commonVariableGroupId -envVarGroupId $groupEnvVariableGroupId -envId $environmentId -flowTemplateRepoId $flowTemplateRepoId -flowTemplateProjectId $flowTemplateProjectId
;

```

### Submit code

```powershell
git add .
$comment = Read-Host("Comment")
git commit -m $comment
git push

```

### Run Pipeline

```powershell
.\documentation\scripts\devops\runPipeline.ps1 -pipelineId $pipelineId -branch $branchName -SkipApiConnections true;

```

### View last pipeline stages

```powershell
. .\documentation\scripts\devops\viewLatestPipelineRun.ps1 -pipelineId $pipelineId

```

### Create RR Flow

```yaml
## Request Response Get Products
  - task: AzureResourceManagerTemplateDeployment@3
    displayName: "Release getproducts RR flow"
    inputs:
      connectedServiceName: ${{ parameters.ServiceConnection }}
      location: $(Location)
      resourceGroupName: $(resourceGroup)
      csmFile: "$(Pipeline.Workspace)/**/flowtemplates/**/rrworkflow.bicep"
      overrideParameters: >
        -parameterNames []
        -urlTemplate "/products"
        -requestPreProcess 
        -requestMapName 
        -requestPostProcess 
        -targetUrl https://thenewappapphello.kindpebble-8ed0ec78.germanywestcentral.azurecontainerapps.io/products
        -relayHeaders CustomHeader:Test
        -responsePreProcess 
        -responseMapName
        -responsePostProcess
        -appName $(AppName)
        -location $(deployLocation)
        -env $(environmentPostFix)
        -partnerName $(partnerName)
        -methodType GET
        -relayMethodType GET
        -name getproducts
        -contentType application/json

```

#### Set API Management KEY

```powershell

$APIM_Context = New-AzApiManagementContext -ResourceGroupName $commonRgName -ServiceName "${appName}-${env}-apim"

$apiSubKey = Get-AzApiManagementSubscriptionKey -Context $APIM_Context -SubscriptionId master | Select-Object -ExpandProperty PrimaryKey

```

#### Test RR 

```powershell

curl "https://${appName}-${env}-apim.azure-api.net/${domainName}/products" -H "oip-key:$apiSubKey"

```

### Remove 

```powershell

### Pipeline

.\documentation\scripts\cleanup\clean_domain.ps1 -domainName $domainName

. .\documentation\scripts\devops\deletePipeline.ps1 -systemName $domainName

Remove-Item .\domains\$domainName -Force -Recurse

git add .

git commit -m "Removed Domain folder"

git push


```
