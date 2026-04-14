## Path

### Deployment

```bash

kubectl apply --filename - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello3-deployment
spec:
  selector:
    matchLabels:
      app: hello3
  template:
    metadata:
      labels:
        app: hello3
    spec:
      containers:
        - name: hello3-container
          image: mcr.microsoft.com/azuredocs/aks-helloworld:v1
          env:
            - name: TITLE
              value: 'app3'
---
apiVersion: v1
kind: Service
metadata:
  name: hello3-service
spec:
  selector:
    app: hello3
  ports:
    - name: http
      port: 80
      targetPort: 80
EOF


```

### HttpRoute

```bash

kubectl apply --filename - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: hello3-httproute
spec:
  parentRefs:
  - name: example-gateway
  rules:
    - backendRefs:
      - name: hello3-service
        kind: Service
        port: 80
      matches:
        - path:
            type: PathPrefix
            value: /hello3
      filters:
        - type: URLRewrite
          urlRewrite:
            path:
              type: ReplaceFullPath
              replaceFullPath: /	
EOF

```

### Call

> From within node

```bash

GATEWAY_NODEPORT=$(kubectl get svc -A | grep LoadB | awk -F'[:/ ]+' '{ print $7 }')

GATEWAY_NODEPORT=$(kubectl get svc -A -o jsonpath='{.items[?(@.spec.type=="LoadBalancer")].spec.ports[0].nodePort}')
curl "localhost:$GATEWAY_NODEPORT/hello3"

```