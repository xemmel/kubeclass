### login to Azure

```powershell

az login -u "studentKuber202305xx@integration-it.com" -p "...."

```

### Install Azure CLI

```powershell

choco install azure-cli -y


```

### Get kubernetes Cluster API Key Certificate

```powershell

az aks get-credentials --name iitaks  --resource-group rg-aks --overwrite-existing;

```
