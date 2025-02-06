```bash

cat <<EOF > preflight.yaml
#cloud-config
package_update: true
package_upgrade: true

write_files:
  - path: /etc/modules-load.d/containerd.conf
    content: |
      overlay
      br_netfilter
  - path: /etc/sysctl.d/99-kubernetes-cri.conf
    content: |
      net.bridge.bridge-nf-call-iptables = 1
      net.bridge.bridge-nf-call-ip6tables = 1
      net.ipv4.ip_forward = 1

runcmd:
  # Disable swap
  - swapoff -a
  - sed -i '/swap/d' /etc/fstab

  # Load necessary modules
  - modprobe overlay
  - modprobe br_netfilter

  # Apply sysctl params
  - sysctl --system

  # Remove conflicting packages
  - for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do apt-get remove -y $pkg; done

  # Install required packages
  - apt-get install -y ca-certificates curl gpg apt-transport-https

  # Add Docker GPG key
  - mkdir -p -m 0755 /etc/apt/keyrings
  - curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  - chmod a+r /etc/apt/keyrings/docker.asc

  # Add Docker repository
  - echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo ${UBUNTU_CODENAME:-$VERSION_CODENAME}) stable" | tee /etc/apt/sources.list.d/docker.list

  # Update package lists
  - apt-get update

  # Install containerd
  - apt-get install -y containerd.io

  # Configure containerd
  - mkdir -p /etc/containerd
  - containerd config default | tee /etc/containerd/config.toml
  - sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
  - systemctl restart containerd
  - systemctl enable containerd

  # Add Kubernetes GPG key
  - curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

  # Add Kubernetes repository
  - echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list
 
  # Update package lists
  - apt-get update

  # Install kubelet, kubeadm, and kubectl
  - apt-get install -y kubelet kubeadm kubectl
  - apt-mark hold kubelet kubeadm kubectl

  # Enable kubelet service
  - systemctl enable --now kubelet

  # pull kubeadm related image
  - sudo kubeadm config images pull
  
EOF

```