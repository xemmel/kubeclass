## Create simple deployment

- Create a simple *deployment*, apply it and scale it up and down
  - Notice: a *deployment* consists of a *replicaset* that again consists of a *pod specification*
     - A **pod** is responsible for hosting one or more *containers* in *kubernetes*
     - A **replicaset** is responsible for running x numbers of *pods* in a *desired state*
     - A **deployment** is responsible for deploying and re-deploying a *replicaset* with different *rollout schemes* and zero down-time if configured

### linux

#### Apply the deployment

```bash

cat << EOF > deployment.yaml
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
          image: nginxdemos/hello
EOF

kubectl create namespace deploymentdemo

kubectl config set-context --current --namespace deploymentdemo

kubectl apply --filename deployment.yaml

```

#### View deployment, replicatset and pods

```bash

kubectl get all

```

#### View pods

```bash

kubectl get pods --output wide

```

#### Scale relicaset up/down

```bash

kubectl scale --replicas=3 deployment/test-deployment

```

#### Cleanup

```bash

kubectl delete --filename deployment.yaml

kubectl delete namespace deploymentdemo

rm deployment.yaml

```
