### Change deployment

```yaml

          env:
            - name: TITLE
              valueFrom:
                configMapKeyRef:
                  name: appx-configmap
                  key: thetitle

```


### New configMap yaml

```yaml

apiVersion: v1
kind: ConfigMap
metadata:
  name: appx-configmap
data:
  thetitle: appxtitle!!!
  thetitle2: appxtitl2

```

### Rollout start (brand new deployment)

```powershell

kubectl rollout restart deployment.apps/appx-deployment

```


### Secrets

```powershell

kubectl create secret generic appx-secret --from-literal=thetitle=verysecrettitle

```

```yaml

          env:
            - name: TITLE
              valueFrom:
                secretKeyRef:
                  name: appx-secret
                  key: thetitle

```