## Feb. 2025


### Create debug pod 
```powershell

kubectl create namespace debugpod

kubectl run debugpod --image nginx --namespace debugpod

```

### Use Debug pod

```powershell

kubectl exec -it debugpod --namespace debugpod -- bash

```

### Curl service other namespace

```powershell

curl [serviceName].[nameSpaceName]

```


#### Multi node cluster

```powershell

### remove old cluster
kind delete cluster

### Create a cluster manifest for multiple worker nodes
$manifest = @"
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
- role: worker
"@;

echo $manifest >> multi.yaml

kind create cluster --config .\multi.yaml

### Create a namespace
kubectl create namespace appx
### Switch context
kubectl config set-context --current --namespace appx
### Create deployment/service
....



kubectl get all

### get all pods with ip address and node
kubectl get pods -o wide
```

### Maintanance

```powershell

## Unschedule (cordon)
kubectl cordon [nodename]

### "Shuffle" the deck
kubectl rollout restart deployment.apps/simple-deployment

## Schedule again
kubectl uncordon [nodename]

### Drain (Evict all existing pods and unschedule)
kubectl drain [nodename] --ignore-daemonsets

```

### Secrets

Change deployment (hello-world)
```yaml

      containers:
        - name: mypod
          image: mcr.microsoft.com/azuredocs/aks-helloworld:v1
          env:
            - name: TITLE
              valueFrom:
                secretKeyRef:
                  name: simple-secret
                  key: thetitle

```

```powershell

kubectl create secret generic simple-secret --from-literal="thetitle=This title has spaces"
```


### Volumes

```powershell

kind delete cluster

$manifest = @"
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
  extraMounts:
  - hostPath: c:/temp/kindstorage/files
    containerPath: /var/local-path-provisioner
"@

echo $manifest >> volume.yaml

kind create cluster --config .\volume.yaml


$mani2 = @"
apiVersion: v1
kind: ConfigMap
metadata:
   name: mongo-cm
data:
  user: theuser
  password: thepassword
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mongo-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: standard
  resources:
    requests:
      storage: 5Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mongodb-deployment
spec:
  replicas: 1
  selector: 
    matchLabels:
      app: mongodbpod
  template:
    metadata:
      labels:
        app: mongodbpod
    spec:
      containers:
      - image: mongo
        name: mongodbcontainer
        env:
          - name: MONGO_INITDB_ROOT_USERNAME
            valueFrom:
              configMapKeyRef:
                name: mongo-cm
                key: user
          - name: MONGO_INITDB_ROOT_PASSWORD
            valueFrom:
              configMapKeyRef:
                name: mongo-cm
                key: password
        volumeMounts:
          - mountPath: /data/db
            name: mongodb  
      volumes:
        - name: mongodb
          persistentVolumeClaim:
            claimName: mongo-pvc
      
---
apiVersion: v1
kind: Service
metadata:
  name: mongodb-service
spec:
  selector:
    app: mongodbpod
  ports:
    - port: 27017
      targetPort: 27017
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mongoexpress-deployment
spec:
  replicas: 1
  selector: 
    matchLabels:
      app: mongoexpress
  template:
    metadata:
      labels:
        app: mongoexpress
    spec:
      containers:
      - image: mongo-express
        name: mongoexpresscontainer
        env:
          - name: ME_CONFIG_MONGODB_ADMINUSERNAME
            valueFrom:
              configMapKeyRef:
                name: mongo-cm
                key: user
          - name: ME_CONFIG_MONGODB_ADMINPASSWORD
            valueFrom:
              configMapKeyRef:
                name: mongo-cm
                key: password
          - name: ME_CONFIG_MONGODB_SERVER
            value: mongodb-service
          - name: ME_CONFIG_BASICAUTH
            value: 'false'
---
apiVersion: v1
kind: Service
metadata:
  name: mongoexpress-service
spec:
  selector:
    app: mongoexpress
  ports:
    - port: 8081
      targetPort: 8081
"@

echo $mani2 >> mongo.yaml

kubectl create namespace mongo
kubectl config set-context --current -namespace mongo
kubectl apply --filename mongo.yaml

kubectl get pv,pvc

kubectl delete pod .....

kubectl port-forward service/mongoexpress-service 5000:8081

Browe: localhost:5000

```