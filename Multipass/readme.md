## Multipass


### Init

```bash

sudo iptables -P FORWARD ACCEPT


multipass launch --name kube-template --disk 30G --memory 4G --cpus 2

https://github.com/xemmel/kubeclass/tree/master/Teacher/Own_Cluster/multipass

multipass stop kube-template

multipass snapshot --name kubegroundimage kube-template

```

### Create Nodes

```bash

multipass clone --name con-1-large kube-template
multipass clone --name wor-1-large kube-template

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


kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/tigera-operator.yaml

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/custom-resources.yaml


```

#### Worker node

> In **main** terminal

```bash

JOIN_CMD=$(multipass exec con-1-large -- sudo kubeadm token create --print-join-command)
multipass exec wor-1-large -- sudo bash -c "$JOIN_CMD"

multipass exec con-1-large  -- watch kubectl get nodes

```



#### Remove cluster 


```bash

multipass delete con-1-large --purge
multipass delete wor-1-large --purge



```



