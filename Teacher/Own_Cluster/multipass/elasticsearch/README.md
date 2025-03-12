```bash
cat << EOF | tee elastic.yaml
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
            - mountPath: /var/log/rabbitmq
              name: datamountlog
          env:
            - name: discovery.type
              value: 'single-node'
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
kubectl create namespace elastic
kubectl config set-context --current --namespace elastic
kubectl apply --filename elastic.yaml

kubectl logs -l app=elasticvolume -f

kubectl exec -it debug --namespace debug -- curl elasticvolume-service.elastic:9200

kubectl exec -it debug --namespace debug -- curl elasticvolume-service.elastic:9200/_cat/indices

kubectl exec -it debug --namespace debug -- curl elasticvolume-service.elastic:9200/db1 -X PUT

kubectl rollout restart deployment elasticvolume-deployment
 

```