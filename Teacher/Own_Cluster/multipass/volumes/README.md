### Pure elastic no volumes

```bash

cat << EOF | tee elastic_volume.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: elasticvolume-deployment
spec:
  selector:
    matchLabels:
      app: elasticvolume
  template:
    metadata:
      labels:
        app: elasticvolume
    spec:
      containers:
        - name: elasticvolumeimage
          image: elasticsearch:7.17.7
          env:
            - name: discovery.type
              value: single-node
---
apiVersion: v1
kind: Service
metadata:
  name: elasticvolume-service
spec:
  selector:
    app: elasticvolume
  ports:
    - name: main
      port: 9200
      targetPort: 9200
EOF

```

### Elastic with volumes

```bash

cat << EOF | tee elastic_volume.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: elastic-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: local-path
  resources:
    requests:
      storage: 1Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: elasticvolume-deployment
spec:
  selector:
    matchLabels:
      app: elasticvolume
  template:
    metadata:
      labels:
        app: elasticvolume
    spec:
      containers:
        - name: elasticvolumeimage
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
  name: elasticvolume-service
spec:
  selector:
    app: elasticvolume
  ports:
    - name: main
      port: 9200
      targetPort: 9200
EOF


```

### Execute

```bash

kubectl create namespace elasticvolume
kubectl config set-context --current --namespace elasticvolume

kubectl apply --filename elastic_volume.yaml

kubectl logs -l app=elasticvolume -f

kubectl exec -it debug --namespace debug -- curl elasticvolume-service.elasticvolume:9200

kubectl exec -it debug --namespace debug -- curl elasticvolume-service.elasticvolume:9200/_cat/indices

### Test no volumes
kubectl exec -it debug --namespace debug -- curl elasticvolume-service.elasticvolume:9200/testindex -X PUT
kubectl exec -it debug --namespace debug -- curl elasticvolume-service.elasticvolume:9200/_cat/indices
kubectl rollout restart deployment.apps/elasticvolume-deployment
kubectl logs -l app=elasticvolume -f
kubectl exec -it debug --namespace debug -- curl elasticvolume-service.elasticvolume:9200/_cat/indices


### View local path (if using rancher)
ls /opt/local-path-provisioner


kubectl delete --filename elastic_volume.yaml

```