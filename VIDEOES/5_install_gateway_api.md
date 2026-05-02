# Install Gateway API

## Install Gateway API CRDs

### Standard

```bash
VERSION=$(curl -s https://api.github.com/repos/kubernetes-sigs/gateway-api/releases/latest | jq -r .tag_name)
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/${VERSION}/standard-install.yaml

```

### Experimental

```bash
VERSION=$(curl -s https://api.github.com/repos/kubernetes-sigs/gateway-api/releases/latest | jq -r .tag_name)
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/${VERSION}/experimental-install.yaml

```

## Install a Gateway

### Envoy

#### Install Envoy Gateway

```bash
LATEST=$(helm show chart oci://docker.io/envoyproxy/gateway-helm 2>/dev/null | grep '^version:' | awk '{print $2}')

helm install eg oci://docker.io/envoyproxy/gateway-helm \
  --version "$LATEST" \
  -n envoy-gateway-system \
  --create-namespace \
  --skip-crds

```

## Install Loadbalancer

### MetalLB

#### Install

```bash
VERSION=$(curl -s https://api.github.com/repos/metallb/metallb/releases/latest | jq -r .tag_name)
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/${VERSION}/config/manifests/metallb-native.yaml

```

#### IP Pool and L2

```bash
kubectl apply -f - <<EOF
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: default-pool
  namespace: metallb-system
spec:
  addresses:
    - 192.168.1.240-192.168.1.250
EOF

sleep 10s

kubectl apply -f - <<EOF
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: default
  namespace: metallb-system
EOF

```
