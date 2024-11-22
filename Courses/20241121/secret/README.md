### Create secret from kubectl

```powershell

kubectl create secret generic test-secret --from-literal=title=verysecret
```

```yaml

 image: webapi:1.4
          env:
            - name: thevariable
              valueFrom:
                secretKeyRef:
                  name: test-secret
                  key: title

```