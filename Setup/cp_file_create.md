```bash

cat <<'EOF' > cp.yaml
  # CP
  - sudo kubeadm init --pod-network-cidr=192.168.0.0/16
  - mkdir -p /home/ubuntu/.kube
  - sudo cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config

write_files:
  - path: /home/ubuntu/templates/deployment.yaml
    content: |
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: test-deployment
      spec:
        replicas: 6
        selector:
          matchLabels:
            app: test
        template:
          metadata:
            labels:
              app: test
          spec:
            containers:
              - image: mcr.microsoft.com/azuredocs/aks-helloworld:v1
                name: testpod
      ---
      apiVersion: v1
      kind: Service
      metadata:
        name: test-service
      spec:
        selector:
          app: test
        ports:
          - port: 80
            targetPort: 80
EOF

```