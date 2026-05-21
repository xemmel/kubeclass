# Install Gateway API

## Install Gateway API CRDs

### Standard

```bash
VERSION=$(curl -s https://api.github.com/repos/kubernetes-sigs/gateway-api/releases/latest | jq -r .tag_name)
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/${VERSION}/standard-install.yaml

```

### Experimental

```bash
VERSION=$(curl -s https://api.github.com/repos/kubernetes-sigs/gateway-api/releases/latest | jq -r .tag_name)
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/${VERSION}/experimental-install.yaml

```

## Install a Gateway

### Envoy


#### Install Envoy Gateway full

> No crds present

```bash

helm install eg oci://docker.io/envoyproxy/gateway-helm \
  -n envoy-gateway-system \
  --create-namespace



```

#### Install Envoy Gateway

```bash
LATEST=$(helm show chart oci://docker.io/envoyproxy/gateway-helm 2>/dev/null | grep '^version:' | awk '{print $2}')

helm install eg oci://docker.io/envoyproxy/gateway-helm \
  -n envoy-gateway-system \
  --create-namespace \
  --skip-crds

```

### Install Envoy Gateway with security-policy

```bash
helm template eg-crds oci://docker.io/envoyproxy/gateway-crds-helm \
  --set crds.gatewayAPI.enabled=true \
  --set crds.gatewayAPI.channel=experimental \
  --set crds.envoyGateway.enabled=true \
| kubectl apply --server-side -f -



```

## Install Loadbalancer

### MetalLB

#### All

```bash

VERSION=$(curl -s https://api.github.com/repos/metallb/metallb/releases/latest | jq -r .tag_name)
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/${VERSION}/config/manifests/metallb-native.yaml

sleep 30s

kubectl apply -f - <<EOF
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: default-pool
  namespace: metallb-system
spec:
  addresses:
    - 10.193.226.240-10.193.226.250
EOF

sleep 10s

kubectl apply -f - <<EOF
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: default
  namespace: metallb-system
EOF


```

#### Install

```bash
VERSION=$(curl -s https://api.github.com/repos/metallb/metallb/releases/latest | jq -r .tag_name)
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/${VERSION}/config/manifests/metallb-native.yaml

```

#### IP Pool and L2

```bash
kubectl apply -f - <<EOF
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: default-pool
  namespace: metallb-system
spec:
  addresses:
    - 192.168.1.240-192.168.1.250
EOF

sleep 10s

kubectl apply -f - <<EOF
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: default
  namespace: metallb-system
EOF

```

## Install gatewayclass

```bash
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: maingatewayclass
spec:
  controllerName: gateway.envoyproxy.io/gatewayclass-controller
EOF

```

### Check GatewayClass accepted

```bash
kubectl get gatewayclasses

```

## Install gateway

### No certificate gateway

```bash

kubectl create namespace normal-gateway

kubectl apply --namespace normal-gateway -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: normal-gateway
spec:
  gatewayClassName: maingatewayclass
  listeners:
  - name: http
    protocol: HTTP
    port: 80
    allowedRoutes:
      namespaces:
        from: All
EOF

```

### Self-signed Cert Gateway

#### Create cert and secret

```bash
kubectl create namespace selfsigned-gateway

mkdir gatewaycert

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ./gatewaycert/tls.key \
  -out ./gatewaycert/tls.crt \
  -subj "/CN=localhost"

kubectl create secret tls selfsigned-gateway-tls --namespace selfsigned-gateway \
  --key=./gatewaycert/tls.key \
  --cert=./gatewaycert/tls.crt

rm -rf gatewaycert

```

#### Create gateway

```bash

kubectl apply --namespace selfsigned-gateway -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: selfsigned-gateway
spec:
  gatewayClassName: maingatewayclass
  listeners:
  - name: https
    protocol: HTTPS
    port: 443
    allowedRoutes:
      namespaces:
        from: All
    tls:
      mode: Terminate
      certificateRefs:
      - kind: Secret
        group: ""
        name: selfsigned-gateway-tls
EOF

```

#### Create Helloapp on selfsigned-gateway

> use /hello

```bash

kubectl create namespace hello-app

kubectl apply --namespace hello-app -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-app
spec:
  selector:
    matchLabels:
      app: hello-app
  template:
    metadata:
      labels:
        app: hello-app
    spec:
      volumes:
        - name: html
          emptyDir: {}
      initContainers:
        - name: init-html
          image: busybox
          command:
            - sh
            - -c
            - echo "hello-app" > /usr/share/nginx/html/index.html
          volumeMounts:
            - name: html
              mountPath: /usr/share/nginx/html
      containers:
        - name: hello-app
          image: nginx
          ports:
            - containerPort: 80
          volumeMounts:
            - name: html
              mountPath: /usr/share/nginx/html
---
apiVersion: v1
kind: Service
metadata:
  name: hello-app
spec:
  selector:
    app: hello-app
  ports:
    - name: http
      port: 80
      targetPort: 80
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: hello-app-httproute
spec:
  parentRefs:
  - name: selfsigned-gateway
    namespace: selfsigned-gateway
  rules:
    - backendRefs:
      - name: hello-app
        kind: Service
        port: 80
      matches:
        - path:
            type: PathPrefix
            value: /hello
      filters:
        - type: URLRewrite
          urlRewrite:
            path:
              type: ReplaceFullPath
              replaceFullPath: /
EOF


```

### Test hello

```bash

WORKER_NODE_IP=$(kubectl get nodes -o wide | grep worker | awk ' {print $6}')
LOAD_BALANCER_PORT=$(kubectl get services -A | grep LoadB | grep selfsigned | awk '{ print $6 }' | awk -F":" '{ print $2 }' | awk -F"/" ' { print $1 }')


curl https://$WORKER_NODE_IP:$LOAD_BALANCER_PORT/hello  --insecure

```
