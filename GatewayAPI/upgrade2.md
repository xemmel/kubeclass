## API GATEWAY CHANGE

Kubernetes 1.35

```bash


multipass stop worker1-flowgrait-k8s control-plane-flowgrait-k8s --force

multipass restore --destructive control-plane-flowgrait-k8s.clean
multipass restore --destructive worker1-flowgrait-k8s.clean

multipass start control-plane-flowgrait-k8s worker1-flowgrait-k8s

multipass shell control-plane-flowgrait-k8s





helm pull oci://docker.io/envoyproxy/gateway-helm


helm show chart oci://docker.io/envoyproxy/gateway-helm
helm show values oci://docker.io/envoyproxy/gateway-helm > envoy-default-values.yaml


helm show values oci://docker.io/envoyproxy/gateway-helm
helm show values oci://docker.io/envoyproxy/gateway-crds-helm



VERSION=$(curl -s https://api.github.com/repos/kubernetes-sigs/gateway-api/releases/latest | jq -r .tag_name)
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/${VERSION}/experimental-install.yaml


kubectl delete crd \
  tcproutes.gateway.networking.k8s.io \
  udproutes.gateway.networking.k8s.io


ORG_ENVOY_VERSION="v1.7.2"

helm pull oci://docker.io/envoyproxy/gateway-crds-helm \
  --version $ORG_ENVOY_VERSION \
  --untar



helm template eg ./gateway-crds-helm \
  --version $ORG_ENVOY_VERSION \
  --set crds.gatewayAPI.enabled=false \
  --set crds.envoyGateway.enabled=true \
  | kubectl apply --server-side --validate=false -f -


kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: maingatewayclass
spec:
  controllerName: gateway.envoyproxy.io/gatewayclass-controller
EOF



kubectl get gatewayclasses


helm install envoy-gateway oci://docker.io/envoyproxy/gateway-helm \
  --version $ORG_ENVOY_VERSION \
  --namespace envoy-gateway-system \
  --create-namespace \
  --skip-crds






kubectl get gatewayclasses






kubectl create namespace debug && kubectl run --namespace debug debug --image nginx



kubectl exec -it --namespace debug debug -- bash






helm install envoy-gateway oci://docker.io/envoyproxy/gateway-helm \
  --version $ORG_ENVOY_VERSION \
  --namespace envoy-gateway-system \
  --create-namespace \
  --set crds.enabled=false





helm template eg ./gateway-crds-helm \
  --version $ORG_ENVOY_VERSION \
  --set crds.gatewayAPI.enabled=true \
  --set crds.gatewayAPI.channel=experimental \
  --set crds.envoyGateway.enabled=true \
  | kubectl apply --server-side --validate=false -f -




## Upgrade

NEW_ENVOY_VERSION="v1.8.3"

mkdir -p envoy-$NEW_ENVOY_VERSION

helm pull oci://docker.io/envoyproxy/gateway-crds-helm \
  --version $NEW_ENVOY_VERSION \
  --untar \
  --untardir envoy-$NEW_ENVOY_VERSION



helm template eg ./envoy-$NEW_ENVOY_VERSION/gateway-crds-helm \
  --version $NEW_ENVOY_VERSION \
  --set crds.gatewayAPI.enabled=false \
  --set crds.envoyGateway.enabled=true \
  | kubectl apply --server-side --validate=false -f -


helm upgrade envoy-gateway oci://docker.io/envoyproxy/gateway-helm \
  --version $NEW_ENVOY_VERSION \
  -n envoy-gateway-system \
  --set crds.enabled=false




kubectl create namespace hello-apps

create_hello_service() {
    local APP="$1"

    cat <<EOF | kubectl apply -n hello-apps -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${APP}-app
spec:
  selector:
    matchLabels:
      app: ${APP}-app
  template:
    metadata:
      labels:
        app: ${APP}-app
    spec:
      volumes:
        - name: html
          emptyDir: {}
      initContainers:
        - name: init-html
          image: busybox
          command:
            - sh
            - -c
            - echo "${APP}-app" > /usr/share/nginx/html/index.html
          volumeMounts:
            - name: html
              mountPath: /usr/share/nginx/html
      containers:
        - name: ${APP}-app
          image: nginx
          ports:
            - containerPort: 80
          volumeMounts:
            - name: html
              mountPath: /usr/share/nginx/html
---
apiVersion: v1
kind: Service
metadata:
  name: ${APP}-service
spec:
  type: NodePort
  selector:
    app: ${APP}-app
  ports:
    - name: http
      port: 80
      targetPort: 80
EOF
}

create_hello_service hello1
create_hello_service hello2
create_hello_service hello3
create_hello_service hello4



### kubectl delete namespace hello-apps


```