## Elastic

### Deployment

```bash

kubectl apply --filename - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: elastic-deployment
spec:
  selector:
    matchLabels:
      app: elastic
  template:
    metadata:
      labels:
        app: elastic
    spec:
      containers: 
        - name: elastic-container
          image: elasticsearch:9.1.5
          env:
            - name: discovery.type
              value: "single-node"
            - name: xpack.security.enabled
              value: "false"
---
apiVersion: v1
kind: Service
metadata:
  name: elastic-service
spec:
  selector:
    app: elastic
  ports:
    - name: http
      port: 9200
      targetPort: 9200
EOF
```

### HttpRoute

```bash

kubectl apply --filename - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: elastic-httproute
spec:
  parentRefs:
  - name: example-gateway
  rules:
    - backendRefs:
      - name: elastic-service
        kind: Service
        port: 9200
      matches:
        - path:
            type: PathPrefix
            value: /elastic
      filters:
        - type: URLRewrite
          urlRewrite:
            path:
              type: ReplacePrefixMatch
              replacePrefixMatch: /	 
EOF

```