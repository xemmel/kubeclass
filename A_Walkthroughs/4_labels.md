## Label Nodes

```bash

kubectl label nodes worker1-flowgrait-k8s gputype=h100

kubectl label nodes worker2-flowgrait-k8s gputype=h200
kubectl label nodes worker3-flowgrait-k8s gputype=h200


```

### Create namespace

```bash

kubectl create namespace labeltest

```

### Create Deployment to run on h100

```bash

kubectl apply --namespace labeltest --filename - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: h100-deployment
spec:
  selector:
    matchLabels:
      app: h100
  template:
    metadata:
      labels:
        app: h100
    spec:
      containers:
        - name: h100-container
          image: nginx
      nodeSelector:
        gputype: h100
EOF


```

### Create Deployment to run on h200

```bash

kubectl apply --namespace labeltest --filename - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: h200-deployment
spec:
  selector:
    matchLabels:
      app: h200
  template:
    metadata:
      labels:
        app: h200
    spec:
      containers:
        - name: h200-container
          image: nginx
      nodeSelector:
        gputype: h200
EOF


```

### Scale

```bash

kubectl scale deployment --namespace labeltest h100-deployment --replicas 4
kubectl scale deployment --namespace labeltest h200-deployment --replicas 4


```

### View pod node distribution

```bash

kubectl get pods --namespace labeltest -o wide

```


### Cleanup

```

kubectl delete namespace labeltest

```