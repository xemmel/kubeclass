## Full


#### Standard Channel

```bash

kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.0/standard-install.yaml

```

#### Standard Channel Latest

```bash

VERSION=$(curl -s https://api.github.com/repos/kubernetes-sigs/gateway-api/releases/latest | jq -r .tag_name)

kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/${VERSION}/standard-install.yaml

```

#### Experimental Channel

```bash

VERSION=$(curl -s https://api.github.com/repos/kubernetes-sigs/gateway-api/releases/latest | jq -r .tag_name)

kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/${VERSION}/experimental-install.yaml

##

```

### Check if Envoy proxy is present

```bash
kubectl get crd | grep -i envoy
kubectl api-resources | grep -i envoy

```

### Install Envoy System with EnvoyProxy 

```bash

helm template eg-crds oci://docker.io/envoyproxy/gateway-crds-helm \
  --version v1.4.6 \
  --set crds.gatewayAPI.enabled=false \
  --set crds.envoyGateway.enabled=true \
  | kubectl apply --server-side -f -

helm install eg oci://docker.io/envoyproxy/gateway-helm \
  --version v1.7.1 -n envoy-gateway-system --create-namespace \
  --set crds.gatewayAPI.enabled=false \
  --set crds.envoyGateway.enabled=true | kubectl apply --server-side -f -

```

### Install Envoy Proxy without envoyproxy (Helm)

```bash


helm install eg oci://docker.io/envoyproxy/gateway-helm \
  --version v1.5.9 \
  -n envoy-gateway-system \
  --create-namespace \
  --skip-crds

##

```

### Intall MetalLB

```bash

VERSION=$(curl -s https://api.github.com/repos/metallb/metallb/releases/latest | jq -r .tag_name)

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/${VERSION}/config/manifests/metallb-native.yaml

## 

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

### Install GatewayClass

```bash

kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: envoy-gatewayclass
spec:
  controllerName: gateway.envoyproxy.io/gatewayclass-controller
EOF

```

### Check GatewayClass accepted

```bash

kubectl get gatewayclasses


```

### Install Gateway and secret

```bash

kubectl create namespace common-gateway

mkdir hellocert

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ./hellocert/tls.key \
  -out ./hellocert/tls.crt \
  -subj "/CN=localhost" \
  -quiet


## Secret in common-gateway namespace

kubectl -n hello create secret tls hello-local-tls --namespace common-gateway \
  --key=./hellocert/tls.key \
  --cert=./hellocert/tls.crt

## kubectl get secret hello-local-tls --namespace local-cert -o yaml



kubectl apply --namespace common-gateway -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: common-envoy-gateway
spec:
  gatewayClassName: envoy-gatewayclass
  listeners:
  - name: http
    protocol: HTTP
    port: 80
    allowedRoutes:
      namespaces:
        from: All
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
        name: hello-local-tls
EOF

```



### Hello Deployment

```bash

kubectl create namespace hello

kubectl apply --namespace hello --filename - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-deployment
spec:
  selector:
    matchLabels:
      app: hello
  template:
    metadata:
      labels:
        app: hello
    spec:
      containers:
        - name: hello-container
          image: mcr.microsoft.com/azuredocs/aks-helloworld:v1
          env:
            - name: TITLE
              value: 'helloapp'
---
apiVersion: v1
kind: Service
metadata:
  name: hello-service
spec:
  selector:
    app: hello
  ports:
    - name: http
      port: 80
      targetPort: 80

EOF

### Hello route

kubectl apply --namespace hello --filename - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: hello-httproute
spec:
  parentRefs:
  - name: common-envoy-gateway
    namespace: common-gateway
  rules:
    - backendRefs:
      - name: hello-service
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

### Hello test

```bash


### Test LoadBalancer

LOADBALANCER_IP=$(kubectl get services -A -o jsonpath='{.items[?(@.spec.type=="LoadBalancer")].status.loadBalancer.ingress[0].ip}')

curl https://${LOADBALANCER_IP}/hello --insecure



### Test Pod

kubectl create namespace debug && kubectl run --namespace debug debug --image nginx

#### Change Service IP address

kubectl exec -it --namespace debug debug -- curl https://10.100.104.136:443/hello --insecure




### Test call hello

GATEWAY_NODEPORT_80=$(kubectl get svc -A -o jsonpath='{.items[?(@.spec.type=="LoadBalancer")].spec.ports[0].nodePort}')

GATEWAY_NODEPORT_443=$(kubectl get svc -A -o jsonpath='{.items[?(@.spec.type=="LoadBalancer")].spec.ports[1].nodePort}')

curl "localhost:$GATEWAY_NODEPORT_80/hello"

curl "https://localhost:$GATEWAY_NODEPORT_443/hello" --insecure
curl "https://localhost:$GATEWAY_NODEPORT_443/hello2" --insecure


```



### Cleanup

```bash

kubectl delete namespace hello
kubectl delete namespace hello2

kubectl delete namespace common-gateway

kubectl delete gatewayclass envoy-gatewayclass

rm -rf hellocert


```


### Create Hello 2 other namespace

```bash

kubectl create namespace hello2

kubectl apply --namespace hello2 --filename - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-deployment
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
              value: 'hello2app'
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

### Hello route

kubectl apply --namespace hello2 --filename - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: hello2-httproute
spec:
  parentRefs:
  - name: common-envoy-gateway
    namespace: common-gateway
  rules:
    - backendRefs:
      - name: hello2-service
        kind: Service
        port: 80
      matches:
        - path:
            type: PathPrefix
            value: /hello2
      filters:
        - type: URLRewrite
          urlRewrite:
            path:
              type: ReplaceFullPath
              replaceFullPath: /	
EOF



```