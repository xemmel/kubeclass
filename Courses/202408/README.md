
```powershell


$namespace = "demo1"

kubectl create namespace $namespace

## Change context to another namespace

kubectl config set-context --current --namespace $namespace


kubectl apply --filename .\deployment.yaml
kubectl apply --filename .\service.yaml


## Show all pods, services, deployment, replicasets

kubectl get all  

### Change no. of replicas

kubectl apply --filename .\deployment.yaml

### Describe service
kubectl describe service thethird-service

### Verify endpoints

kubectl get pods -o wide


```



### Create debug pod

```powershell

kubectl create namespace debugpod

kubectl run debugpod --image nginx --namespace debugpod


```

### Use Debug pod

```powershell

kubectl exec -it debugpod --namespace debugpod -- bash

```

### View Application Log in a single pod

```powershell


kubectl logs pod/day2-deployment-8488f9d449-dxknm -f

```

### View Application log based on label (multi-pods)

```powershell

kubectl logs -l app=day2 -f

```

### Expose Service on the outside (debug)

```powershell

kubectl port-forward service/day2-service 6000:80

```



### Config Map

configMap.yaml

```yaml

apiVersion: v1
kind: ConfigMap
metadata:
  name: theconfigmap
data:
  title: 'The ConfigMap new title'


```


kubectl apply --filename .\configMap.yaml

##### Change the deployment:

```powershell

        image: mcr.microsoft.com/azuredocs/aks-helloworld:v1
        env:
          - name: TITLE
            valueFrom:
              configMapKeyRef:
                name: theconfigmap
                key: title

```

deploy again

-> Verify new title




## Yaml rules

```json
{
    "id" : "17"

}

```

```yaml

id: 17
```

```json
{
    "address" : {
        "street" : "Vej"
    }

}

```

```yaml

address:
  street: Vej

```

```json
{
  "matchLabels": {
    "app": "thethird",
    "morten": "morten2"
  }
}
```

```yaml

matchLabels:
    app: thethird
    morten: morten2

```


```json

{
  "people" : [ "Morten",  "Morten2" ]
}

```

```yaml
people:
  - Morten
  - Morten2

```

```json

{
  "people" : [
    {
        "name": "Morten",
        "address" : "what"
    },
    {
        "name": "Morten2",
        "address" : "what2"
    },
    {
        "address" : "what3"
    }
   ],
   "pp" ....
}

```

```yaml
people:
  - name: Morten
    address: what
  - name: Morten2
    address: what2
  - address: what3
pp:
```


### LivenessProbe

```powershell

  spec:
      containers:
        - name: failingapi-container
          image: failingwebapi:0.3
          livenessProbe:
            httpGet:
              path: /health
              port: 8080

```