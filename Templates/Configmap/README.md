## Inject ConfigMap in Deployment

```yaml
        env:
        - name: TITLE
          valueFrom:
            configMapKeyRef:
              name: my3demo-config
              key: thetitle

```


### Create Secret with kubectl

```powershell

kubectl create secret generic demo2-secret --from-literal=thepassword=verysecret

```

## Inject Secret in Deployment

```yaml

        env:
        - name: TITLE
          valueFrom:
            secretKeyRef:
              name: demo2-secret
              key: thepassword

```