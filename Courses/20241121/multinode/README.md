### Delete old cluster

kind delete cluster --name kind

### Create multinode cluster

kind create cluster --name multi --config multinode_kind.yaml


### deploy a deployment again

- create namespace
- switch namespace
kubectl apply --filename ....

#### Check the pod distribution

kubectl get pods -o wide


### Get nodes

kubectl get nodes

#### Cordon (Unschedule)

kubectl cordon [nodename]

#### unCordon (schedule)

kubectl uncordon [nodename]

### Drain

kubectl drain [nodename] --ignore-daemonsets

### Rollout restart a deployment

kubectl rollout restart [deploymentname]

example: kubectl rollout restart deployment.apps/hellotest-deployment

