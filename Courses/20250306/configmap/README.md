### Re-deployment


```powershell

kubectl rollout restart deployment.apps/hello-deployment

```

### Manual use as env var

```yaml
          - name: TITLE
            valueFrom:
              configMapKeyRef:
                name: hello-cm
                key: TITLE
```

### Inject all key/values as env var

```yaml
          name: nginx-container
          envFrom:
            - configMapRef:
                name: hello-cm
```

### Use config map as file (volume)


```yaml

          image: mcr.microsoft.com/azuredocs/aks-helloworld:v1
          volumeMounts:
            - name: appconfig
              mountPath: "/mlcappconfig"
              readOnly: true
      volumes:
        - name: appconfig
          configMap:
            name: hello-cm

```

