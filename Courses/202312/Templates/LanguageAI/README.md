$value = Read-Host("api-key");

kubectl create secret generic ailanguage-secret --from-literal=apikey=$value;


