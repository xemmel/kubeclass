## Kubernetes setup

### Multipass create template server

```bash

multipass launch --name kube-template --disk 30G --memory 4G --cpus 2

multipass launch --name kube-template --disk 30G --memory 4G --cpus 2 devel


multipass shell kube-template

```

### Create newest image 3 servers directly

```bash

multipass launch --name con-1-latest --disk 30G --memory 6G --cpus 2 devel
multipass launch --name wor-1-latest --disk 30G --memory 6G --cpus 2 devel
multipass launch --name client-1-latest --disk 30G --memory 2G --cpus 2 devel


```

### Setup kubeadm, containerd etc

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

### Stop the template

```bash

multipass stop kube-template


```

### Create nodes

```bash

multipass clone --name con-1-large kube-template
multipass clone --name wor-1-large kube-template
multipass clone --name client-1-large kube-template

multipass start client-1-large


multipass set local.con-1-large.memory=6G
multipass set local.wor-1-large.memory=6G

multipass start con-1-large wor-1-large

```

### Create cluster

```bash

multipass shell con-1-large

sudo kubeadm init --pod-network-cidr=192.168.0.0/16

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# kubectl get nodes

## Completion
sudo apt-get install -y bash-completion
echo "source <(kubectl completion bash)" >> ~/.bashrc
source ~/.bashrc

CALICO_VERSION=$(curl -fsSL https://api.github.com/repos/projectcalico/calico/releases/latest \
  | grep '"tag_name"' \
  | sed -E 's/.*"([^"]+)".*/\1/')


kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/${CALICO_VERSION}/manifests/tigera-operator.yaml
sleep 15s
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/${CALICO_VERSION}/manifests/custom-resources.yaml


```

### Add Worker node

- In Root server

```bash

JOIN_CMD=$(multipass exec con-1-large -- sudo kubeadm token create --print-join-command)
multipass exec wor-1-large -- sudo bash -c "$JOIN_CMD"




```

### Take snapshot of nodes

```bash

multipass stop wor-1-large con-1-large

multipass info con-1-large.clean >/dev/null 2>&1 && multipass delete con-1-large.clean --purge
multipass info wor-1-large.clean >/dev/null 2>&1 && multipass delete wor-1-large.clean --purge

multipass snapshot --name clean con-1-large
multipass snapshot --name clean wor-1-large

multipass start con-1-large wor-1-large

```

### Clean all nodes/servers

```bash

multipass stop wor-1-large con-1-large

multipass restore --destructive con-1-large.clean
multipass restore --destructive wor-1-large.clean

multipass start con-1-large wor-1-large


multipass delete client-1-large --purge
multipass clone --name client-1-large kube-template
multipass start client-1-large


```