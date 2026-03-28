## Contour

### Install ingress

#### Auto

```bash

kubectl apply -f https://projectcontour.io/quickstart/contour.yaml


```

#### Manual namespace

> Line numbers may differ in future

```bash

wget https://projectcontour.io/quickstart/contour.yaml 

sed '16,20d' contour.yaml -i

kubectl create namespace projectcontour

kubectl apply --filename contour.yaml

rm contour.yaml


```

### Install Gateway

#### Auto

```bash

kubectl apply -f https://projectcontour.io/quickstart/contour-gateway-provisioner.yaml

```

#### Manual Namespace

```bash

wget https://projectcontour.io/quickstart/contour-gateway-provisioner.yaml

sed '26145,26149d' contour-gateway-provisioner.yaml -i

kubectl create namespace projectcontour

kubectl apply --filename contour-gateway-provisioner.yaml

rm contour-gateway-provisioner.yaml

```

#### Create GatewayClass and Gateway

```bash


kubectl apply -f - <<EOF
kind: GatewayClass
apiVersion: gateway.networking.k8s.io/v1
metadata:
  name: contour
spec:
  controllerName: projectcontour.io/gateway-controller
EOF



kubectl apply -f - <<EOF
kind: Gateway
apiVersion: gateway.networking.k8s.io/v1
metadata:
  name: contour
  namespace: projectcontour
spec:
  gatewayClassName: contour
  listeners:
    - name: http
      protocol: HTTP
      port: 80
      allowedRoutes:
        namespaces:
          from: All
EOF


```

#### Intall default page

```bash

kubectl create namespace defaulthttpbin

kubectl apply -f https://projectcontour.io/examples/httpbin.yaml --namespace defaulthttpbin


NODEPORT=$(kubectl get service --namespace projectcontour envoy -o=jsonpath='{ .spec.ports[?(@.port=='80')].nodePort }')

#### Gateway
NODEPORT=$(kubectl get service --namespace projectcontour envoy-contour -o=jsonpath='{ .spec.ports[?(@.port=='80')].nodePort }')


curl "localhost:$NODEPORT"


```