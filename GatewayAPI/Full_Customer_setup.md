## Full

```bash


helm install eg oci://docker.io/envoyproxy/gateway-helm --version v1.7.1 -n envoy-gateway-system --create-namespace --skip-crds


kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: envoy-gatewayclass
spec:
  controllerName: gateway.envoyproxy.io/gatewayclass-controller
EOF

kubectl create namespace hello


mkdir hellocert

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ./hellocert/tls.key \
  -out ./hellocert/tls.crt \
  -subj "/CN=localhost"

  ls ./hellocert -l


kubectl -n hello create secret tls hello-local-tls --namespace hello \
  --key=./hellocert/tls.key \
  --cert=./hellocert/tls.crt

kubectl get secret hello-local-tls --namespace hello


kubectl apply --namespace hello -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: hello-envoy-gateway
spec:
  gatewayClassName: envoy-gatewayclass
  listeners:
  - name: http
    protocol: HTTP
    port: 80
  - name: https
    protocol: HTTPS
    port: 443
    tls:
      mode: Terminate
      certificateRefs:
      - kind: Secret
        group: ""
        name: hello-local-tls
EOF


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


kubectl apply --namespace hello --filename - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: hello-httproute
spec:
  parentRefs:
  - name: hello-envoy-gateway
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


kubectl get pods,services,gateway,httproutes --namespace hello


### Test Pod

kubectl create namespace debug && kubectl run --namespace debug debug --image nginx

#### Change Service IP address

kubectl exec -it --namespace debug debug -- curl https://10.100.104.136:443/hello --insecure




### Test call hello

GATEWAY_NODEPORT_80=$(kubectl get svc -A -o jsonpath='{.items[?(@.spec.type=="LoadBalancer")].spec.ports[0].nodePort}')

GATEWAY_NODEPORT_443=$(kubectl get svc -A -o jsonpath='{.items[?(@.spec.type=="LoadBalancer")].spec.ports[1].nodePort}')

curl "localhost:$GATEWAY_NODEPORT_80/hello"

curl "https://localhost:$GATEWAY_NODEPORT_443/hello" --insecure


### Cleanup

kubectl delete namespace hello

kubectl delete gatewayclass envoy-gatewayclass

rm -rf hellocert


```