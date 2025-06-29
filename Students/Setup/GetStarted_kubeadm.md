## Real cluster

## Create linux servers

```bash

multipass launch --name con-1 --disk 20G --memory 2G --cpus 2
multipass launch --name wor-1 --disk 20G --memory 2G --cpus 2
multipass launch --name wor-2 --disk 20G --memory 2G --cpus 2

```

## enter server

```bash

multipass shell con-1

```

## Get latest version

```bash

curl -L -s https://dl.k8s.io/release/stable.txt

```

## Install containerd, kubelet, kubeadm, kubectl

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

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list


sudo apt-get update

sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sudo systemctl enable --now kubelet
sudo kubeadm config images pull



```

## configure cluster (add control plane)

```bash

sudo kubeadm init --pod-network-cidr=192.168.0.0/16

```




## configure kubectl

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

## Setup network

```bash

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/tigera-operator.yaml

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/custom-resources.yaml

watch kubectl get pods -A

```

## add worker node

```bash

### in control plane

kubeadm token create --print-join-command

### in worker node

sudo ....


```

## List containerd runnning containers

```bash

sudo ctr -n k8s.io containers list

```