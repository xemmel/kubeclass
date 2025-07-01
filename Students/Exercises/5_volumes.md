## create new kind cluster

> Save file as cluster.yaml

```yaml

kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
  extraMounts:
  - hostPath: c:/temp/kindstorage/files
    containerPath: /var/local-path-provisioner

```

```powershell

kind get clusters

kind delete cluster --name ....

kind create cluster --name volume --config cluster.yaml

```

## create deployment and pvc


```yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: elastic-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: elastic
  template:
    metadata:
      labels:
        app: elastic
    spec:
      containers:
        - name: elastic-container
          image: elasticsearch:7.17.7
          volumeMounts:
            - mountPath: /usr/share/elasticsearch/data
              name: datamount
          env:
            - name: discovery.type
              value: single-node
          
      volumes:
        - name: datamount
          persistentVolumeClaim:
            claimName: elastic-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: elastic-service
spec:
  selector:
    app: elastic
  ports:
    - port: 9200
      targetPort: 9200

```


```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: elastic-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: standard
  resources:
    requests:
      storage: 3Gi

```


### View PV,PVC

```yaml

kubectl get pv,pvc

```
