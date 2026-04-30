## Full chart

### Setup Chart Env

```bash

mkdir helm_charts
cd helm_charts

```

### Setup Chart

```bash

CHARTNAME="httptest"

mkdir -p $CHARTNAME/templates

cat<<EOF>>$CHARTNAME/Chart.yaml
apiVersion: v2
name: $CHARTNAME
type: application
version: 1.0.0
appVersion: "1.0.0"
EOF

cat<<EOF> $CHARTNAME/values.yaml
image:
  name: nginx
ports:
  port: 80
  targetPort: 80
EOF

mkdir -p "$CHARTNAME"/customers/{customer1,customer2}

cat<<EOF> $CHARTNAME/customers/customer1/values.yaml
customerIds:
  - '10'
  - '11'
EOF

cat<<EOF> $CHARTNAME/customers/customer2/values.yaml
customerIds:
  - "13"
EOF


```

### Create templates

```bash

cat<<EOF> $CHARTNAME/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.app.name }}-deployment
spec:
  selector:
    matchLabels:
      app: {{ .Values.app.name }}
  template: 
    metadata:
      labels:
        app: {{ .Values.app.name }}
    spec:
      containers:
        - name: {{ .Values.app.name }}-container
          image: {{ .Values.image.name }}
EOF

cat<<EOF> $CHARTNAME/templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.app.name }}
spec:
  selector:
    app: {{ .Values.app.name }}
  ports:
    - name: http
      port: {{ .Values.ports.port }}
      targetPort: {{ .Values.ports.targetPort }}
EOF



cat<<EOF> $CHARTNAME/templates/httproute.yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: {{ .Values.app.name }}-httproute
spec:
  parentRefs:
  - name: common-envoy-gateway
    namespace: common-gateway
  rules:
    - backendRefs:
      - name: {{ .Values.app.name }}
        kind: Service
        port: {{ .Values.ports.port }}
      matches:
       {{- range .Values.customerIds }}
        - path:
            value: /
          headers:
            - name: "y-customer"
              value: {{ . | quote }}
       {{- end }}
      filters:
        - type: URLRewrite
          urlRewrite:
            path:
              type: ReplaceFullPath
              replaceFullPath: /	
EOF

```

### Deploy customer1

```bash

helm install customer1-release ./$CHARTNAME --set=app.name=customer1app --values ./$CHARTNAME/customers/customer1/values.yaml --namespace customer1 --create-namespace



```

### Test

```bash

LOADBALANCER_IP=$(kubectl get services -A -o jsonpath='{.items[?(@.spec.type=="LoadBalancer")].status.loadBalancer.ingress[0].ip}')

curl https://${LOADBALANCER_IP} --insecure -H "y-customer:10" ## Should hit

curl https://${LOADBALANCER_IP} --insecure -H "y-customer:11" ## Should hit 

curl https://${LOADBALANCER_IP} --insecure -H "y-customer:12" ## Should not hit


```

### Cleanup

```bash


kubectl get namespaces | grep -i customer | awk '{ print $1 }' | xargs -I {} kubectl delete namespace {}

rm -rf $CHARTNAME

```

