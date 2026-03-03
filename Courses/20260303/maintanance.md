
### multi

```bash

kind get clusters
kind delete cluster --name kind

 




cat << EOF >> multicluster.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker
EOF

kind create cluster --name multicluster --config multicluster.yaml

kubectl create namespace demo01
kubectl config set-context --current --namespace demo01


cat << EOF >> deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
spec:
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: web-container
          image: nginx
---
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  selector:
    app: web
  ports:
    - port: 80
      targetPort: 80
EOF


kubectl apply --filename deployment.yaml


kubectl scale deployment web-deployment --replicas 5


### Maintanance


#### Cordon (un-schedule)

kubectl cordon multicluster-worker2


## Restart

kubectl rollout restart deployment web-deployment


#### Uncordon (re-schedule)

kubectl uncordon multicluster-worker2

### Drain (Kill exiting pods on node AND cordon)

kubectl drain multicluster-worker2 --ignore-daemonsets

## Do a ucordon after maintanance


```


