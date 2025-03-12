```bash
cat << EOF | tee rabbitmq.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: rabbitmq-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: local-path
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: rabbitmqlog-pvc
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
  name: rabbitmqvolume-deployment
spec:
  selector:
    matchLabels:
      app: rabbitmqvolume
  template:
    metadata:
      labels:
        app: rabbitmqvolume
    spec:
      containers:
        - name: rabbitmqvolumeimage
          image: rabbitmq:4.0-management
          volumeMounts:
            - mountPath: /var/log/rabbitmq
              name: datamountlog
            - mountPath: /var/lib/rabbitmq
              name: datamount
          env:
            - name: RABBITMQ_DEFAULT_USER
              value: user
            - name: RABBITMQ_DEFAULT_PASS
              value: password
            - name: RABBITMQ_NODENAME
              value: node1
      volumes:
        - name: datamount
          persistentVolumeClaim:
            claimName: rabbitmq-pvc
        - name: datamountlog
          persistentVolumeClaim:
            claimName: rabbitmqlog-pvc

---
apiVersion: v1
kind: Service
metadata:
  name: rabbitmqvolume-service
spec:
  selector:
    app: rabbitmqvolume
  ports:
    - name: main
      port: 15672
      targetPort: 15672
EOF

```



### Execute

```bash

kubectl create namespace rabbit
kubectl config set-context --current --namespace rabbit

kubectl apply --filename rabbitmq.yaml


kubectl logs -l app=rabbitmqvolume -f


kubectl exec -it debug --namespace debug -- curl -u user:password rabbitmqvolume-service.rabbit:15672/api/queues

### Create test queue
kubectl exec -it debug --namespace debug -- curl -u user:password -X PUT -H "Content-Type: application/json" -d '{"durable": true}' http://rabbitmqvolume-service.rabbit:15672/api/queues/%2F/test-queue1



kubectl exec -it debug --namespace debug -- curl -u user:password http://rabbitmqvolume-service.rabbit:15672/api/queues | jq '.durable'


kubectl rollout restart deployment rabbitmqvolume-deployment


### If on same node as pod created
ls /opt/local-path-provisioner/


kubectl delete --filename rabbitmq.yaml

kubectl delete namespace rabbit

```