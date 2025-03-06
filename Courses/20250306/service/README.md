```powershell
kubectl exec -it debug --namespace debug -- bash

curl helloapp-service.test01

kubectl exec -it debug --namespace debug -- curl helloapp-service.test01

```

### Change TITLE to pod name

```yaml

              valueFrom:
                fieldRef:
                  fieldPath: metadata.name

```

### Log with label and prefix

```powershell

kubectl logs -l app=helloapp -f --prefix

```