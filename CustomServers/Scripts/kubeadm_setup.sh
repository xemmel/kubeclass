sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/kubernetes-archive-keyring.gpg >/dev/null

sudo apt-get update

VERSION=1.26.5-00

sudo apt-get install -y kubelet=$VERSION kubeadm=$VERSION kubectl=$VERSION 
sudo apt-mark hold kubelet kubeadm kubectl containerd

sudo systemctl enable kubelet.service
sudo systemctl enable containerd.service

