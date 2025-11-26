### Volumes

```bash

### Clean up

CLUSTERNAME=$(kind get clusters)
kind delete cluster --name $CLUSTERNAME


### Create volume cluster

mkdir volumes
cd volumes

#### You may need to change dmin??

cat<<EOF>>volumes.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
  extraMounts:
  - hostPath: /home/dmin/kindstorage/files
    containerPath: /var/local-path-provisioner
EOF

kind create cluster --name volume --config volumes.yaml

cat<<EOF>>elastic_pvc.yaml
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
      storage: 2Gi
EOF

cat<<EOF>>deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: elastic-deployment
spec:
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
          env:
            - name: discovery.type
              value: single-node
          volumeMounts:
            - mountPath: /usr/share/elasticsearch/data
              name: datavolume
      volumes:
        - name: datavolume
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
EOF

kubectl create namespace demo
kubectl config set-context --current --namespace demo


kubectl apply --filename elastic_pvc.yaml
kubectl apply --filename deployment.yaml

kubectl get pv,pvc

ls ../kindstorage/files

```

### Debug

```bash

kubectl create namespace debug && kubectl run debug --namespace debug --image nginx

kubectl exec -it --namespace debug debug -- sh -c "curl elastic-service.demo:9200/_cat/indices"


kubectl exec -it --namespace debug debug -- sh -c "curl elastic-service.demo:9200/db1 -X PUT"


```



