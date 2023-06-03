sudo iptables -I INPUT -p tcp --dport 179 -j ACCEPT
sudo iptables -I INPUT -p ipip -j ACCEPT
sudo iptables -I INPUT -p udp --dport 4789 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 5473 -j ACCEPT
sudo iptables -I INPUT -p udp --dport 51820 -j ACCEPT
sudo iptables -I INPUT -p udp --dport 51821 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 2379 -j ACCEPT


sudo kubeadm init --kubernetes-version v1.27.0 --pod-network-cidr=192.168.0.0/16

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.0/manifests/tigera-operator.yaml
curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.0/manifests/custom-resources.yaml -O
kubectl create -f custom-resources.yaml

