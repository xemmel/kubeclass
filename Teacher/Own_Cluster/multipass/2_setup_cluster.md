```bash
### Setup (on master)
sudo kubeadm init --pod-network-cidr=192.168.0.0/16

```

### Untaint

```bash

kubectl taint node con-1-large  node-role.kubernetes.io/control-plane:NoSchedule-

```