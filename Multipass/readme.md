## Multipass


### Install

```bash

## If snap is not installed

sudo apt update
sudo apt install snapd


sudo snap install multipass

```

### Launch

```bash

multipass launch --name server --disk 30G --memory 4G --cpus 2
multipass launch --name newest --disk 30G --memory 4G --cpus 2 devel

```

### Init

```bash

sudo iptables -P FORWARD ACCEPT


multipass launch --name kube-template --disk 30G --memory 4G --cpus 2

https://github.com/xemmel/kubeclass/tree/master/Teacher/Own_Cluster/multipass

multipass stop kube-template

## multipass snapshot --name kubegroundimage kube-template

```

### Update template

```bash

multipass start kube-template
multipass exec kube-template -- sudo apt update
multipass exec kube-template -- sudo apt upgrade -y
multipass stop kube-template


```

### Create Nodes

```bash

### With client

multipass clone --name con-1-large kube-template
multipass clone --name wor-1-large kube-template
multipass clone --name client-1-large kube-template

multipass start con-1-large wor-1-large client-1-large

### Without client

multipass clone --name con-1-large kube-template
multipass clone --name wor-1-large kube-template

multipass start con-1-large wor-1-large 




```

### Create cluster

```bash


multipass shell con-1-large

sudo apt update && sudo apt upgrade -y

sudo kubeadm init --pod-network-cidr=192.168.0.0/16


		
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# kubectl get nodes

## Completion
sudo apt-get install -y bash-completion
echo "source <(kubectl completion bash)" >> ~/.bashrc
source ~/.bashrc


kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/tigera-operator.yaml
sleep 10s
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/custom-resources.yaml


```

#### Worker node

> In **main** terminal

```bash

multipass exec wor-1-large -- sudo apt update
multipass exec wor-1-large -- sudo apt upgrade -y


JOIN_CMD=$(multipass exec con-1-large -- sudo kubeadm token create --print-join-command)
multipass exec wor-1-large -- sudo bash -c "$JOIN_CMD"

multipass exec con-1-large  -- watch kubectl get nodes

```

### Take/Use snapshot

```bash

## Take snapshot of con/wor

multipass stop wor-1-large con-1-large

multipass info con-1-large.clean >/dev/null 2>&1 && multipass delete con-1-large.clean --purge
multipass info wor-1-large.clean >/dev/null 2>&1 && multipass delete wor-1-large.clean --purge

multipass snapshot --name clean con-1-large
multipass snapshot --name clean wor-1-large

multipass start con-1-large wor-1-large


## Clear cluster to clean snapshot

multipass stop wor-1-large con-1-large


multipass restore --destructive con-1-large.clean
multipass restore --destructive wor-1-large.clean

multipass start con-1-large wor-1-large



### Check
multipass exec con-1-large -- kubectl get nodes

multipass exec con-1-large -- kubectl get namespaces

multipass exec con-1-large -- kubectl create namespace mustgo


```

### Clean client server

```bash

multipass delete client-1-large --purge
multipass clone --name client-1-large kube-template
multipass start client-1-large


```



#### Remove cluster 


```bash

multipass delete con-1-large --purge
multipass delete wor-1-large --purge


## Client
multipass delete client-1-large --purge




```



