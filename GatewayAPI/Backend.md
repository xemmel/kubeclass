## Backend Routing

> For Envoy Gateway

### Enable Backend Routing

> Warning: Can be misused


```bash

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: envoy-gateway-config
  namespace: envoy-gateway-system
data:
  envoy-gateway.yaml: |
    apiVersion: gateway.envoyproxy.io/v1alpha1
    kind: EnvoyGateway
    provider:
      type: Kubernetes
    gateway:
      controllerName: gateway.envoyproxy.io/gatewayclass-controller
    extensionApis:
      enableBackend: true
EOF


```

### Check config map

```bash

kubectl get configmap --namespace envoy-gateway-system envoy-gateway-config -o yaml

```

### Restart pod

```bash

kubectl rollout restart deployment envoy-gateway -n envoy-gateway-system

```


### Apply HttpRoute


```bash


cat <<EOF | kubectl apply -f -
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: backend
spec:
  parentRefs:
    - name: example-gateway
  rules:
    - backendRefs:
        - group: gateway.envoyproxy.io
          kind: Backend
          name: httpbin
      matches:
        - path:
            type: PathPrefix
            value: /external
      filters:
        - type: URLRewrite
          urlRewrite:
            path:
              type: ReplaceFullPath
              replaceFullPath: /a4136773-486a-441e-a222-8687f41a3eae
---
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: Backend
metadata:
  name: httpbin
  namespace: default
spec:
  endpoints:
    - fqdn:
        hostname: webhook.site
        port: 443
  tls:
    insecureSkipVerify: true
EOF

```