## Volumes

### Install local StorageClass

- Does not support auto PV (missing CSI?)

```bash

kubectl apply --filename - <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner # indicates that this StorageClass does not support automatic provisioning
volumeBindingMode: WaitForFirstConsumer
EOF

```

### Install rancher local-path StorageClass

```bash
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml

```

### PVC for elastic

```bash

kubectl create namespace elastic
kubectl config set-context --current --namespace elastic


kubectl apply --filename - <<EOF
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
EOF

```

### Create Elastic Deployment/Service

```bash

kubectl apply --filename - <<EOF
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
          image: elasticsearch:9.1.5
          env:
            - name: 'xpack.security.enabled'
              value: 'false'
            - name: 'discovery.type'
              value: 'single-node'
            - name: ES_JAVA_OPTS
              value: "-Xms512m -Xmx512m"
          resources:
            requests:
                memory: "1Gi"
                cpu: "250m"
            limits:
                memory: "1Gi"
                cpu: "1"
          volumeMounts:
            - mountPath: /usr/share/elasticsearch/data
              name: datamount
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
EOF

```

### Debug

```bash

kubectl create namespace debug
kubectl run debug --namespace debug --image nginx

kubectl exec -it --namespace debug debug -- bash


curl elastic-service.elastic:9200
curl elastic-service.elastic:9200/_cat/indices

curl elastic-service.elastic:9200/morten -X PUT


kubectl logs $(kubectl get pods -o name | tail -n 1)

kubectl delete $(kubectl get pods -o name | tail -n 1)

multipass exec wor-1-large -- ls /opt/local-path-provisioner

```

### Clean up

```bash

kubectl delete namespace elastic

```

### Remove Storageclass

```bash

kubectl delete storageclass local-storage

```