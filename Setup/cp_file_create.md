cat <<'EOF' > cp.yaml
  # CP
  - sudo kubeadm init --pod-network-cidr=192.168.0.0/16
  - mkdir -p /home/ubuntu/.kube
  - sudo cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
EOF