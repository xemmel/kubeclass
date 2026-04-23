## Hello Headers

```bash

kubectl create namespace hello1headers
kubectl create namespace hello2headers


kubectl apply --namespace hello1headers --filename - <<EOF
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
              value: 'hello-header-test-app1'
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

EOF

kubectl apply --namespace hello2headers --filename - <<EOF
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
              value: 'hello-header-test-app2'
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



### Hello1 route

kubectl apply --namespace hello1headers --filename - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: hello1-httproute
spec:
  parentRefs:
  - name: common-envoy-gateway
    namespace: common-gateway
  rules:
    - backendRefs:
      - name: hello1-service
        kind: Service
        port: 80
      matches:
        - path:
            value: /
          headers:
            - name: "x-customer"
              value: "1"
      filters:
        - type: URLRewrite
          urlRewrite:
            path:
              type: ReplaceFullPath
              replaceFullPath: /	
EOF


### Hello2 route

kubectl apply --namespace hello2headers --filename - <<EOF
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
            value: /
          headers:
            - name: "x-customer"
              value: "2"
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

LOADBALANCER_IP=$(kubectl get services -A -o jsonpath='{.items[?(@.spec.type=="LoadBalancer")].status.loadBalancer.ingress[0].ip}')

curl https://${LOADBALANCER_IP} --insecure -H "x-customer:1"
curl https://${LOADBALANCER_IP} --insecure -H "x-customer:2"


```

