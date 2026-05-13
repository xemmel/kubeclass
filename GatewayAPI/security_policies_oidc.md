# Security policies OIDC

## Setup Service and HTTPRoute

> With host: securetest.mortenlacour.com
> get /app

```bash

KNAMESPACE="securegatewayapp"

kubectl create namespace $KNAMESPACE

cat <<EOF | kubectl apply --namespace $KNAMESPACE --filename -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: securehello-app
spec:
  selector:
    matchLabels:
      app: securehello-app
  template:
    metadata:
      labels:
        app: securehello-app
    spec:
      initContainers:
        - name: init-html
          image: busybox
          command:
            - sh
            - -c
            - echo "securehello-app greeting" > /usr/share/nginx/html/index.html
          volumeMounts:
            - name: html
              mountPath: /usr/share/nginx/html
      containers:
        - name: securehello-app-container
          image: nginx
          volumeMounts:
            - name: html
              mountPath: /usr/share/nginx/html
      volumes:
        - emptyDir: {}
          name: html
---
apiVersion: v1
kind: Service
metadata:
  name: securehello-app
spec:
  selector:
    app: securehello-app
  ports:
    - name: http
      port: 80
      targetPort: 80
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: securehello-app
spec:
  parentRefs:
    - group: gateway.networking.k8s.io
      kind: Gateway
      name: selfsigned-gateway
      namespace: selfsigned-gateway
  hostnames: ["securetest.mortenlacour.com"]
  rules:
    - backendRefs:
        - group: ""
          kind: Service
          name: securehello-app
          port: 80
          weight: 1
      filters:
        - type: URLRewrite
          urlRewrite:
            path:
              replaceFullPath: /
              type: ReplaceFullPath
      matches:
        - path:
            type: PathPrefix
            value: /app
EOF


```

## Apply Security-Policy


### Set parameters

```bash


CLIENTSECRET="wpR..."

CLIENTID="685536a1-b4df-45ae-b1e8-a77853d25d6a"
REDIRECT_URL="https://securetest.mortenlacour.com/app/oauth2/callback"
ISSUER="https://sts.windows.net/551c586d-a82d-4526-b186-d061ceaa589e/"

```

### Create Client-Secret secret

```bash

kubectl create secret generic securehello-app-secret --from-literal="client-secret=${CLIENTSECRET}" --namespace $KNAMESPACE

kubectl create secret generic gateway-secret --from-literal="client-secret=${CLIENTSECRET}" --namespace selfsigned-gateway


```

### Apply on HTTPRoute

```bash
cat <<EOF | kubectl apply --namespace $KNAMESPACE --filename -
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: SecurityPolicy
metadata:
  name: securehello-app-policy
spec:
  targetRefs:
    - group: gateway.networking.k8s.io
      kind: HTTPRoute
      name: securehello-app
  oidc:
    provider:
      issuer: "${ISSUER}"
    clientID: "${CLIENTID}"
    clientSecret:
      name: "securehello-app-secret"
    redirectURL: "${REDIRECT_URL}"
    logoutPath: "/app/logout"
EOF

```
#### Remove

```bash
kubectl delete securitypolicy securehello-app-policy --namespace $KNAMESPACE

```

### Apply on Gateway

```bash
cat <<EOF | kubectl apply --namespace selfsigned-gateway --filename -
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: SecurityPolicy
metadata:
  name: gateway-policy
spec:
  targetRefs:
    - group: gateway.networking.k8s.io
      kind: Gateway
      name: selfsigned-gateway
  oidc:
    provider:
      issuer: "${ISSUER}"
    clientID: "${CLIENTID}"
    clientSecret:
      name: "gateway-secret"
    redirectURL: "${REDIRECT_URL}"
    logoutPath: "/app/logout"
EOF

```

#### Remove

```bash
kubectl delete securitypolicy gateway-policy --namespace selfsigned-gateway

kubectl delete secret gateway-secret --namespace selfsigned-gateway


```



### Test

```bash

WORKER_NODE_IP=$(kubectl get nodes -o wide | grep worker | awk ' {print $6}')
LOAD_BALANCER_PORT=$(kubectl get services -A | grep LoadB | grep selfsigned | awk '{ print $6 }' | awk -F":" '{ print $2 }' | awk -F"/" ' { print $1 }')


curl https://$WORKER_NODE_IP:$LOAD_BALANCER_PORT/app -H "Host:securetest.mortenlacour.com" --insecure

curl https://$WORKER_NODE_IP:$LOAD_BALANCER_PORT/app -H "Host:securetest.mortenlacour.com" --insecure -v


```

### Remove policy

```bash

kubectl delete securitypolicy securehello-app-policy --namespace $KNAMESPACE


```