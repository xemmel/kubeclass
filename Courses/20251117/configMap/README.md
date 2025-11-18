### Re-deployment


```powershell

kubectl rollout restart deployment.apps/hello-deployment

```

### Manual use as env var (1)

```yaml
       - image: mcr.microsoft.com/azuredocs/aks-helloworld:v1
          name: helloworld5
          env: 
            - name: TITLE
              valueFrom:
                configMapKeyRef:
                  name: hello-cm
                  key: TITLE
```

### Inject all key/values as env var (2)

```yaml
          name: nginx-container
          envFrom:
            - configMapRef:
                name: hello-cm
```

### Use config map as file (volume) (3)


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

### Secrets

```yaml

          valueFrom:
            secretKeyRef:
              name: test-secret
              key: thepassword

```

#### apply secret from kubectl

```powershell

kubectl create secret generic test-secret --from-literal=thepassword=verysecret

```

#### Secret as yaml (we do not like)

```yaml

apiVersion: v1
kind: Secret
metadata:
  name: test-secret
data:
  thepassword: dmVyeXNlY3JldA==
type: Opaque

```
