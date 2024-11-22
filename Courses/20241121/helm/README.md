```powershell

helm install appx-test chart1/ --namespace appx-prod --create-namespace --values chart1/prod-values.yaml  --set appName=appx

```