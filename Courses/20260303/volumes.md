## Volumes

```bash

## Delete existing kind cluster

cat << EOF >> volumecluster.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
  extraMounts:
  - hostPath: /home/teknoadm/kubernetesdata
    containerPath: /var/local-path-provisioner
EOF

kind create cluster --name volume --config volumecluster.yaml

cat << EOF >> pvc_elastic.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-elastic
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: standard
  resources:
    requests:
      storage: 2Gi
EOF

cat << EOF >> elastic.yaml
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
          volumeMounts:
            - mountPath: /usr/share/elasticsearch/data
              name: datamount
      volumes:
        - name: datamount
          persistentVolumeClaim:
            claimName: pvc-elastic
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


kubectl create namespace demo01
kubectl config set-context --current --namespace demo01

kubectl apply --filename pvc_elastic.yaml

kubectl get pv,pvc

kubectl apply --filename elastic.yaml



kubectl create namespace debug && kubectl run --namespace debug debug --image nginx
kubectl exec -it --namespace debug debug -- bash


### Check indices
curl elastic-service.demo01:9200/_cat/indices

### Create index
curl elastic-service.demo01:9200/db1 -X PUT


### Remove deployment

kubectl delete --filename elastic.yaml

```