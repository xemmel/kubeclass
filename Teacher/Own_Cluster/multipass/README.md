```bash
sudo iptables -P FORWARD ACCEPT

rm cp_temp.yaml
cat preflight.yaml > cp_temp.yaml
cat cp.yaml >> cp_temp.yaml


multipass launch --name cp-1 --cloud-init cp_temp.yaml --disk 20G --memory 2G --cpus 2


kubectl create namespace debug
kubectl run debug --image nginx --namespace debug

kubectl exec -it debug --namespace debug -- bash

kubectl exec -it debug --namespace debug -- curl test-service.test01:9200


```

```bash

cat << EOF | tee elastic_deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: test
  template:
    metadata:
      labels:
        app: test
    spec:
      containers:
        - image: elasticsearch:7.17.27
          name: test-container
          env:
            - name: 'discovery.type'
              value: 'single-node'
---
apiVersion: v1
kind: Service
metadata:
  name: test-service
spec:
  selector:
    app: test
  ports:
    - port: 9200
      targetPort: 9200
EOF

```