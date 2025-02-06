## Multipass Kubernetes


In WSL HOST Maybe:
```bash

sudo iptables -P FORWARD ACCEPT

multipass launch --name client
multipass exec client -- ping www.eb.dk
```
### Perm (Not working)

sudo iptables-save | sudo tee /etc/iptables/rules.v4

### Check after cp-1 get ip

multipass exec cp-1 -- ping www.eb.dk



multipass exec cp-1 -- ping www.eb.dk
multipass exec cp-1 -- ctr
multipass exec cp-1 -- kubectl

multipass info cp-1


watch multipass list

### Create CP
```bash

cat preflight.yaml > cp_temp.yaml
cat cp.yaml >> cp_temp.yaml


multipass launch --name cp-1 --cloud-init cp_temp.yaml --disk 20G --memory 4G --cpus 2

multipass shell cp-1

sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/custom-resources.yaml

watch kubectl get pods -n calico-system

rm cp_temp.yaml

multipass exec cp-1 -- kubectl
multipass exec cp-1 -- kubectl get nodes

```
### CP



sudo kubeadm init --pod-network-cidr=192.168.0.0/16
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

multipass shell cp-1

sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/custom-resources.yaml

watch kubectl get pods -n calico-system


### In worker get command from cp

sudo kubeadm token create --print-join-command

### Join worker
```bash

WORKERNAME="worker-1"
multipass launch --name $WORKERNAME --cloud-init preflight.yaml --disk 20G --memory 2G --cpus 2

multipass exec cp-1 -- sudo kubeadm token create --print-join-command
multipass exec $WORKERNAME -- sudo 
multipass exec cp-1 -- kubectl get nodes -w

```

### Clean

```bash

multipass delete cp-1
multipass delete worker-1

multipass purge
rm preflight.yaml


multipass delete --all
multipass purge


```

