## Gateway API

### Install Helm

```bash

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
chmod 700 get_helm.sh
./get_helm.sh

echo "source <(helm completion bash)" >> ~/.bashrc
source ~/.bashrc


```

### Install CRDS Envoy

```bash

helm install eg oci://docker.io/envoyproxy/gateway-helm \
  -n envoy-gateway-system \
  --create-namespace

```


### Install Gatewayclass

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

### Install normal gateway

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

### Install deployment,service,httproute

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
  - name: normal-gateway
    namespace: normal-gateway
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

### Test

```bash

kubectl get services -A
## Find loadbalancer (normal-)  (IP address)

kubectl create namespace debug && kubectl run --namespace debug debug --image nginx

kubectl exec -it --namespace debug debug -- bash

curl ipaddress/hello

```