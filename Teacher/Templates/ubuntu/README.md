
```

kubectl run hello2 --image mcr.microsoft.com/azuredocs/aks-helloworld:v1 --env TITLE=yo --dry-run=client -o yaml | Set-Clipboard

```


```
kubectl run ubuntu2 --image ubuntu --dry-run=client -o yaml -- /bin/sleep 3600 | Set-Clipboard

```