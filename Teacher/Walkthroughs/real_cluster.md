### Real cluster setup




### Create master node

```bash

sudo iptables -P FORWARD ACCEPT


multipass launch --name con-1-large --disk 30G --memory 4G --cpus 2

```

### Create template node

```bash
multipass launch --name template-large --disk 30G --memory 4G --cpus 2

### Update it

multipass stop template-large


multipass clone --name con-1-large template-large
multipass clone --name wor-1-large template-large
multipass start con-1-large
multipass start wor-1-large



```

### Create worker nodes

```bash
multipass launch --name wor-1-large --disk 30G --memory 4G --cpus 2
multipass launch --name wor-2-large --disk 30G --memory 4G --cpus 2



``` 

[Back to top](#real-cluster-setup)

### Prereq for all nodes

```bash

sudo apt update 

sudo apt upgrade -y

### pre-configure

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

K8S_VERSION=$(curl -fsSL https://dl.k8s.io/release/stable.txt)
K8S_MINOR=${K8S_VERSION%.*}


curl -fsSL "https://pkgs.k8s.io/core:/stable:/${K8S_MINOR}/deb/Release.key" \
  | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/${K8S_MINOR}/deb/ /" \
| sudo tee /etc/apt/sources.list.d/kubernetes.list


sudo apt-get update

sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sudo systemctl enable --now kubelet
sudo kubeadm config images pull


```

[Back to top](#real-cluster-setup)


### Clone master to worker nodes

```bash

multipass stop con-1-large
multipass clone --name wor-1-large con-1-large
multipass clone --name wor-x-large con-1-large
multipass start con-1-large
multipass start wor-1-large



```

[Back to top](#real-cluster-setup)

### Setup cluster

```bash

sudo kubeadm init --pod-network-cidr=192.168.0.0/16

```

[Back to top](#real-cluster-setup)


### Kubectl configure

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

[Back to top](#real-cluster-setup)




### Install  network

```bash
### Not working 

CALICO_TAG="$(curl -fsSL https://api.github.com/repos/projectcalico/calico/releases/latest | jq -r .tag_name)"

kubectl create -f "https://raw.githubusercontent.com/projectcalico/calico/${CALICO_TAG}/manifests/tigera-operator.yaml"
sleep 10
kubectl create -f "https://raw.githubusercontent.com/projectcalico/calico/${CALICO_TAG}/manifests/custom-resources.yaml"

```


[Back to top](#real-cluster-setup)

### Add a worker node

```bash
### First do the pre-configure

### Or
WORKER_NODE_NUMBER="2"

NODE_NAME="wor-${WORKER_NODE_NUMBER}-large"

multipass clone --name $NODE_NAME template-large
multipass start $NODE_NAME
multipass shell $NODE_NAME



#### In master
kubeadm token create --print-join-command

watch kubectl get nodes


```

[Back to top](#real-cluster-setup)

### Take snapshot of server

```bash

SERVER_NAME="con-1-large"
multipass stop $SERVER_NAME
multipass snapshot --name "${SERVER_NAME}-snap" $SERVER_NAME
multipass start $SERVER_NAME


```
[Back to top](#real-cluster-setup)

### Restore snapshot

```bash
SERVER_NAME="con-1-large"
multipass stop $SERVER_NAME
multipass restore --destructive "${SERVER_NAME}.${SERVER_NAME}-snap"
multipass start $SERVER_NAME

```

[Back to top](#real-cluster-setup)

### Debug pod 

```bash

kubectl create namespace debug && kubectl run --namespace debug debug --image nginx

```

[Back to top](#real-cluster-setup)

### Cleanup

```bash

multipass delete con-1-large --purge
multipass delete wor-1-large --purge
multipass delete wor-2-large --purge


```

[Back to top](#real-cluster-setup)
