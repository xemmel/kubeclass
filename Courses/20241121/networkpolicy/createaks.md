```powershell

az aks create \
  --name ojaks \
  --resource-group $RGNAME \
  --location spaincentral \
  --min-count 2 \
  --max-count 3 \
  --enable-cluster-autoscaler \
  --network-policy azure \
  --network-plugin azure




az aks get-credentials \
  --name ojaks \
  --resource-group $RGNAME



```