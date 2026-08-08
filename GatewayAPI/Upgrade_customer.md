## Versions

```

My Kubernetes: v1.36.3
SIT Kubernetes: v1.35.2
AI Kubernetes: 
   - CP: v1.35.3
   - Wo: v1.36.0

```

## Restore

```bash

multipass stop worker1-flowgrait-k8s control-plane-flowgrait-k8s --force

multipass restore --destructive control-plane-flowgrait-k8s.clean
multipass restore --destructive worker1-flowgrait-k8s.clean

multipass start control-plane-flowgrait-k8s worker1-flowgrait-k8s

multipass shell control-plane-flowgrait-k8s

```

### CRDS

```bash

VERSION=$(curl -s https://api.github.com/repos/kubernetes-sigs/gateway-api/releases/latest | jq -r .tag_name)
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/${VERSION}/experimental-install.yaml

```

### Install envoy gateway with existing CRDS

#### Set Version
```bash

## ENVOY_VERSION="v1.8.3"
ENVOY_VERSION="v1.7.2"

```

### Install

```bash

rm crds.yaml -f

helm template eg-crds oci://docker.io/envoyproxy/gateway-crds-helm   \
 	--version $ENVOY_VERSION   \
	--set crds.gatewayAPI.enabled=false   \
	--set crds.envoyGateway.enabled=true  | kubectl apply --server-side --force-conflicts --validate=false -f -


```

### Get Gateway API Version

```bash

kubectl get crd gateways.gateway.networking.k8s.io \
  -o jsonpath='{.metadata.annotations.gateway\.networking\.k8s\.io/bundle-version}{"\n"}'

```

### With empty apiVersion fix

```bash

sudo apt install yq -y


yq 'select(.apiVersion != null and .kind != null)' crds.yaml   | kubectl apply --server-side --force-conflicts -f -

```

### Without empty apiVersion fix

```bash

cat crds.yaml   | kubectl apply --server-side --force-conflicts --validate=false -f -
 
```



## Before 1.8.2

```bash
helm install eg oci://docker.io/envoyproxy/gateway-helm \
  --version $ENVOY_VERSION \
  -n envoy-gateway-system \
  --create-namespace \
  --skip-crds

```

## After 1.8.2

```bash

helm install eg oci://docker.io/envoyproxy/gateway-helm \
  --version $ENVOY_VERSION \
  -n envoy-gateway-system \
  --create-namespace \
  --set crds.enabled=false


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

### Check

```bash

kubectl get gatewayclasses

```

### Upgrade

```bash

NEW_VERSION="v1.8.3"

helm template eg-crds oci://docker.io/envoyproxy/gateway-crds-helm \
  --version $NEW_VERSION \
  --set crds.gatewayAPI.enabled=false \
  --set crds.envoyGateway.enabled=true \
    | kubectl apply --server-side --validate=false --force-conflicts -f -



helm upgrade eg oci://docker.io/envoyproxy/gateway-helm \
  --version $NEW_VERSION \
  -n envoy-gateway-system \
  --set crds.enabled=false


```