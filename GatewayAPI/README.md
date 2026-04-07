## Gateway API

### Install CRD

#### Install Helm

```bash

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
chmod 700 get_helm.sh
./get_helm.sh

echo "source <(helm completion bash)" >> ~/.bashrc
source ~/.bashrc



```

#### Envoy Gateway and CRD

```bash

helm install eg oci://docker.io/envoyproxy/gateway-helm --version v1.7.1 -n envoy-gateway-system --create-namespace

kubectl wait --timeout=5m -n envoy-gateway-system deployment/envoy-gateway --for=condition=Available

```

#### Standard Channel

```bash

kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.0/standard-install.yaml

```

#### Experimental Channel

```bash

kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.0/experimental-install.yaml

```

### Simple Gateway and HTTPRoute to Service

```bash

kubectl create namespace gatewaydemo
kubectl config set-context --current --namespace gatewaydemo


### Deployment and Service

kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello1-deployment
spec:
  selector:
    matchLabels:
      app: hello1
  template:
    metadata:
      labels:
        app: hello1
    spec:
      containers:
        - name: hello1-container
          image: mcr.microsoft.com/azuredocs/aks-helloworld:v1
          env:
            - name: TITLE
              value: 'app1'
---
apiVersion: v1
kind: Service
metadata:
  name: hello1-service
spec:
  selector:
    app: hello1
  ports:
    - name: http
      port: 80
      targetPort: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello2-deployment
spec:
  selector:
    matchLabels:
      app: hello2
  template:
    metadata:
      labels:
        app: hello2
    spec:
      containers:
        - name: hello2-container
          image: mcr.microsoft.com/azuredocs/aks-helloworld:v1
          env:
            - name: TITLE
              value: 'app2'
---
apiVersion: v1
kind: Service
metadata:
  name: hello2-service
spec:
  selector:
    app: hello2
  ports:
    - name: http
      port: 80
      targetPort: 80
EOF

### Debug

kubectl create namespace debug && kubectl run debug --namespace debug --image nginx

kubectl exec -it --namespace debug debug -- curl hello1-service.gatewaydemo
kubectl exec -it --namespace debug debug -- curl hello2-service.gatewaydemo

kubectl exec -it --namespace debug debug -- curl 


### GatewayClass

kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: example-gateway
spec:
  controllerName: gateway.envoyproxy.io/gatewayclass-controller
EOF

### Gateway

> Will create a new LoadBalancer Service called *envoy-gatewaydemo-example-gateway-.......*

kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: example-gateway
spec:
  gatewayClassName: example-gateway
  listeners:
  - name: http
    protocol: HTTP
    port: 80
EOF

### HTTPRoutes

kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: hello1-route
spec:
  parentRefs:
  - name: example-gateway
  hostnames:
  - "app1.example.com"
  rules:
  - backendRefs:
    - name: hello1-service
      port: 80
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: hello2-route
spec:
  parentRefs:
  - name: example-gateway
  hostnames:
  - "app2.example.com"
  rules:
  - backendRefs:
    - name: hello2-service
      port: 80
EOF

kubectl exec -it --namespace debug debug -- curl 10.111.216.21 -H "Host: app1.example.com"
kubectl exec -it --namespace debug debug -- curl 10.111.216.21 -H "Host: app2.example.com"


kubectl delete namespace gatewaydemo

```