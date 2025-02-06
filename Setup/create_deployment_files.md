```bash
mkdir templates
cd templates

cat << 'EOF' > deployment.yaml
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

cd ..

kubectl create namespace test
kubectl apply --filename ./templates/deployment.yaml --namespace test


```