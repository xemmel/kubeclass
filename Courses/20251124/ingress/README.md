## Ingress

```bash

### Clean up

CLUSTERNAME=$(kind get clusters)
kind delete cluster --name $CLUSTERNAME

cat<<EOF>>ingress_cluster.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 89
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
- role: worker
EOF

kind create cluster --name ingress --config ingress_cluster.yaml


curl localhost:89

cat<<EOF>>deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webserverhello1-deployment
spec:
  selector:
    matchLabels:
      app: webserverhello1
  template:
    metadata:
      labels:
        app: webserverhello1
    spec:
      containers:
        - name: webserverhello1-container
          image: mcr.microsoft.com/azuredocs/aks-helloworld:v1
          env:
            - name: TITLE
              value: 'app1'
---
---
apiVersion: v1
kind: Service
metadata:
  name: webserverhello1-service
spec:
  selector:
    app: webserverhello1
  ports:
    - port: 80
      targetPort: 80
EOF

cat<<EOF>>ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app1-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
    - http:
        paths:
          - path: /app1
            pathType: Exact
            backend:
              service:
                name: webserverhello1-service
                port:
                  number: 80
EOF

kubectl create namespace ingressdemo
kubectl config set-context --current --namespace ingressdemo


kubectl apply --filename deployment.yaml
kubectl apply --filename ingress.yaml

watch kubectl get ingress

localhost:89/app1

```