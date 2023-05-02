```powershell

kubectl apply -f .\Templates\deployment.yaml


kubectl delete -f .\Templates\deployment.yaml



### Expose Internal Service

kubectl port-forward service/myservice 4444:80

```

## Use Config Map in Deployment (pod) (container)

```yaml

        env:
        - name: TITLE
          valueFrom:
            configMapKeyRef:
              name: myconfigmap
              key: thetitle

```

### Execute inside debug pod (Mortens env.)

```
kubectl exec -it pod -n debug -- bash

```