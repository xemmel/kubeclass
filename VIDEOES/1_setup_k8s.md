# Setup Kubernetes

## Install WSL

```bash

wsl --install Ubuntu-24.04


```

## Install Multipass

```bash

sudo apt update
sudo apt upgrade -y

sudo snap install multipass

```

## Create nodes

### Create Server Template

```bash

sudo iptables --policy FORWARD ACCEPT

multipass launch --name flowgrait-k8s-template --memory 4GB --cpus 2 --disk 20GB devel

multipass shell flowgrait-k8s-template

```

#### Install Prerequisites 


```bash

sudo apt update && sudo apt upgrade -y

cat << EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

cat << EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

sudo swapoff -a
sudo sed -i '/swap/d' /etc/fstab

sudo modprobe overlay
sudo modprobe br_netfilter
sudo sysctl --system


for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove -y ; done

sudo apt-get install -y ca-certificates curl gpg apt-transport-https

sudo mkdir -p -m 0755 /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc


echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu noble stable" | sudo tee /etc/apt/sources.list.d/docker.list


sudo apt-get update

sudo apt-get install -y containerd.io

sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd


K8S_VERSION=$(curl -fsSL https://dl.k8s.io/release/stable.txt | sed 's/^v//; s/\.[0-9]*$//')

curl -fsSL https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update

sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sudo systemctl enable --now kubelet
sudo kubeadm config images pull


```

### Stop Template

> exit first

```bash

multipass stop flowgrait-k8s-template

```

### Create Servers from Template

```bash

multipass clone --name control-plane-flowgrait-k8s flowgrait-k8s-template
multipass clone --name worker1-flowgrait-k8s flowgrait-k8s-template
multipass clone --name client-flowgrait-k8s flowgrait-k8s-template

multipass start client-flowgrait-k8s


multipass set local.control-plane-flowgrait-k8s.memory=6G
multipass set local.worker1-flowgrait-k8s.memory=6G

multipass start control-plane-flowgrait-k8s worker1-flowgrait-k8s


```

## Create Cluster

### Enter Control-plane

```bash

multipass shell control-plane-flowgrait-k8s

```

### Setup Cluster

```bash

POD_IP_RANGE="192.168.0.0/16"

sudo kubeadm init --pod-network-cidr="${POD_IP_RANGE}"

```

### Configure kubectl

```bash

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# kubectl get nodes

## Completion
sudo apt-get install -y bash-completion
echo "source <(kubectl completion bash)" >> ~/.bashrc
source ~/.bashrc


```

### Test kubectl

```bash

kubectl get nodes

```

### Install Helm

```bash

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
chmod 700 get_helm.sh
./get_helm.sh

echo "source <(helm completion bash)" >> ~/.bashrc
source ~/.bashrc


```

### Install Cluster Networking

#### CALICO

```bash

CALICO_VERSION=$(curl -fsSL https://api.github.com/repos/projectcalico/calico/releases/latest \
  | grep '"tag_name"' \
  | sed -E 's/.*"([^"]+)".*/\1/')


kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/${CALICO_VERSION}/manifests/tigera-operator.yaml
sleep 15s
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/${CALICO_VERSION}/manifests/custom-resources.yaml


```

## Add worker-node

```bash

WORKER_NODE_NAME="worker1-flowgrait-k8s"

JOIN_CMD=$(multipass exec control-plane-flowgrait-k8s -- sudo kubeadm token create --print-join-command)
multipass exec $WORKER_NODE_NAME -- sudo bash -c "$JOIN_CMD"

```
### Check worker-node status

```bash

multipass exec control-plane-flowgrait-k8s -- watch kubectl get nodes


```

## Add Additional Worker node

```bash

read -p "Worker number: " WORKER_NUMBER
WORKER_NODE_NAME="worker${WORKER_NUMBER}-flowgrait-k8s"
multipass clone --name $WORKER_NODE_NAME flowgrait-k8s-template
multipass start $WORKER_NODE_NAME

JOIN_CMD=$(multipass exec control-plane-flowgrait-k8s -- sudo kubeadm token create --print-join-command)
multipass exec $WORKER_NODE_NAME -- sudo bash -c "$JOIN_CMD"


```

## Rollout restart deployment

```bash

kubectl rollout restart deployment --namespace test-web test-web-deployment

```

## Remove worker node

```bash

read -p "Worker number: " WORKER_NUMBER
WORKER_NODE_NAME="worker${WORKER_NUMBER}-flowgrait-k8s"
multipass stop $WORKER_NODE_NAME --force
multipass delete $WORKER_NODE_NAME --purge

multipass exec control-plane-flowgrait-k8s -- \
kubectl delete node "${WORKER_NODE_NAME}"


```

## Cleanup terminating pods

```bash

kubectl get pods --namespace test-web | grep -i termin | awk '{ print $1 }' | xargs -I {} kubectl delete pod {} --force --grace-period=0 --namespace test-web


```

## Take Cluster snapshot

```bash

multipass stop worker1-flowgrait-k8s control-plane-flowgrait-k8s

multipass info control-plane-flowgrait-k8s.clean >/dev/null 2>&1 && multipass delete control-plane-flowgrait-k8s.clean --purge
multipass info worker1-flowgrait-k8s.clean >/dev/null 2>&1 && multipass delete worker1-flowgrait-k8s.clean --purge

multipass snapshot --name clean control-plane-flowgrait-k8s
multipass snapshot --name clean worker1-flowgrait-k8s

multipass start control-plane-flowgrait-k8s worker1-flowgrait-k8s


```

## Restore Cluster snapshot

```bash

multipass stop worker1-flowgrait-k8s control-plane-flowgrait-k8s --force

multipass restore --destructive control-plane-flowgrait-k8s.clean
multipass restore --destructive worker1-flowgrait-k8s.clean

multipass start control-plane-flowgrait-k8s worker1-flowgrait-k8s


```

### Test Restored Cluster

```bash

multipass exec control-plane-flowgrait-k8s -- kubectl get namespaces
multipass exec control-plane-flowgrait-k8s -- kubectl get nodes


```

## Test Cluster

### Enter Control-plane

```bash

multipass shell control-plane-flowgrait-k8s

```

### Create nginx deployment

#### Create Deployment

```bash

kubectl create namespace test-web

kubectl apply --namespace test-web --filename - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-web-deployment
spec:
  selector:
    matchLabels:
      app: test-web
  template:
    metadata:
      labels:
        app: test-web
    spec:
      containers:
        - name: test-web-container
          image: nginx
---
apiVersion: v1
kind: Service
metadata:
  name: test-web-service
spec:
  selector:
    app: test-web
  ports:
    - name: http
      port: 80
      targetPort: 80
EOF

##

```

#### Scale to 3

```bash

kubectl scale deployment test-web-deployment --namespace test-web --replicas 3

```

#### Check test-web 

```bash

kubectl get all --namespace test-web

```

### Create Debug Pod

```bash

kubectl create namespace debug && kubectl run debug --image nginx --namespace debug

```

### Enter debug Pod

> Might take a minute to pull image

```bash

kubectl exec -it debug --namespace debug -- bash

```

### NMAP inside debug pod

#### Install nmap
```bash

apt update
apt install nmap -y

```

#### Use nmap

```bash

PODRANGE=$(hostname -I | awk -F"." '{ print $1"."$2"."$3".0/24" }')
nmap -sn $PODRANGE | grep -i report

```


## Scratch Control-plane

```bash
multipass delete control-plane-flowgrait-k8s --purge
multipass clone --name control-plane-flowgrait-k8s flowgrait-k8s-template
multipass set local.control-plane-flowgrait-k8s.memory=6G
multipass start control-plane-flowgrait-k8s
multipass shell control-plane-flowgrait-k8s

```

## Check node pod ip ranges

```bash

kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{" => "}{.spec.podCIDR}{"\n"}{end}'

```

## Clean up Cluster

```bash

multipass delete control-plane-flowgrait-k8s worker1-flowgrait-k8s client-flowgrait-k8s  --purge

```

## Clean up Cluster With Template

```bash

multipass delete control-plane-flowgrait-k8s worker1-flowgrait-k8s client-flowgrait-k8s flowgrait-k8s-template  --purge

```
