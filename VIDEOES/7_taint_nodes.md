## Taint nodes

### Create Two new worker nodes

```bash

WORKER_NODE_NAME="worker2-flowgrait-k8s"
multipass clone --name $WORKER_NODE_NAME flowgrait-k8s-template
multipass start $WORKER_NODE_NAME

JOIN_CMD=$(multipass exec control-plane-flowgrait-k8s -- sudo kubeadm token create --print-join-command)
multipass exec $WORKER_NODE_NAME -- sudo bash -c "$JOIN_CMD"


WORKER_NODE_NAME="worker3-flowgrait-k8s"
multipass clone --name $WORKER_NODE_NAME flowgrait-k8s-template
multipass start $WORKER_NODE_NAME

JOIN_CMD=$(multipass exec control-plane-flowgrait-k8s -- sudo kubeadm token create --print-join-command)
multipass exec $WORKER_NODE_NAME -- sudo bash -c "$JOIN_CMD"

```

### Deploy a normal deployment

#### Create namespace

```bash

kubectl create namespace normal-test

```

#### Deployment

```bash

kubectl apply --namespace normal-test --filename - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: normal-test
spec:
  selector:
    matchLabels:
      app: normal-test
  template:
    metadata:
      labels:
        app: normal-test
    spec:
      containers: 
        - name: normal-test-container
          image: nginx
EOF

```

### List pods

```bash

kubectl get pods --namespace normal-test -o wide

```

### Scale

```bash

kubectl scale deployment --namespace normal-test normal-test --replicas 6

```

### Taint worker node 3 for GPU's

```bash

kubectl taint node worker3-flowgrait-k8s dedicated=gpu:NoSchedule
kubectl label node worker3-flowgrait-k8s dedicated=gpu

```

### View taints

```bash

kubectl describe node worker3-flowgrait-k8s | grep -i taint
kubectl get node worker3-flowgrait-k8s --show-labels

```

### Restart

```bash

kubectl rollout restart deployment --namespace normal-test normal-test

```


### Deployment for GPU

#### Create namespace

```bash

kubectl create namespace gpu-test

```

#### Deployment

```bash

kubectl apply --namespace gpu-test --filename - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gpu-test
spec:
  selector:
    matchLabels:
      app: gpu-test
  template:
    metadata:
      labels:
        app: gpu-test
    spec:
      nodeSelector:
        dedicated: gpu

      tolerations:
        - key: dedicated
          operator: Equal
          value: gpu
          effect: NoSchedule
      containers: 
        - name: gpu-test-container
          image: nginx
EOF


```

### Scale gpu deployment

```bash

kubectl scale deployment --namespace gpu-test gpu-test --replicas 6

```

### View pods

```bash

kubectl get pods --namespace gpu-test -o wide

```

### Remove worker nodes

```bash

WORKER_NODE_NAME="worker3-flowgrait-k8s"
multipass stop $WORKER_NODE_NAME --force
multipass delete $WORKER_NODE_NAME --purge

multipass exec control-plane-flowgrait-k8s -- \
kubectl delete node "${WORKER_NODE_NAME}"


WORKER_NODE_NAME="worker2-flowgrait-k8s"
multipass stop $WORKER_NODE_NAME --force
multipass delete $WORKER_NODE_NAME --purge

multipass exec control-plane-flowgrait-k8s -- \
kubectl delete node "${WORKER_NODE_NAME}"
