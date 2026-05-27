## Simple volume demo

```bash

### Install storageclass (if needed)

kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml

### Set as default (if needed)
kubectl patch storageclass local-path \
  -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'


kubectl create namespace volume-test
kubectl label --overwrite namespace volume-test pod-security.kubernetes.io/enforce=privileged

kubectl apply --namespace volume-test --filename - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-pvc
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
  name: test-deployment
spec:
  selector:
    matchLabels:
      app: test
  template:
    metadata:
      labels:
        app: test
    spec:
      containers:
        - name: test-container
          image: nginx
          volumeMounts:
            - mountPath: /usr/share/nginx/html
              name: datamount
      volumes:
        - name: datamount
          persistentVolumeClaim:
            claimName: test-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: test-service
spec:
  type: NodePort
  selector:
    app: test
  ports:
    - port: 80
      targetPort: 80
EOF


```

### Test

```bash

kubectl exec -it --namespace volume-test $(kubectl get pods --namespace volume-test -o name) -- sh -c 'echo "hello" > /usr/share/nginx/html/index.html'

kubectl exec -it --namespace volume-test $(kubectl get pods --namespace volume-test -o name) -- sh -c 'cat /usr/share/nginx/html/index.html'

kubectl delete $(kubectl get pods --namespace volume-test -o name) --namespace volume-test


```