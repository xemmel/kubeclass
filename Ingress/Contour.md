## Contour

```bash


wget https://projectcontour.io/quickstart/contour.yaml 

wget https://projectcontour.io/examples/httpbin.yaml

### Remove the namespace declaration from contour.yaml



kubectl create namespace projectcontour
## Label stuff on SIT
kubectl apply --filename contour.yaml

watch kubectl get pods -A





kubectl create namespace debug
kubectl run --namespace debug debug --image nginx

kubectl exec -it --namespace debug debug -- bash

curl envoy.projectcontour



### Default http page
kubectl create namespace defaulthttppage
kubectl apply --filename httpbin.yaml --namespace defaulthttppage



### Hello


cat <<EOF>>hello_deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-deployment
spec:
  replicas: 3
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
          image: nginx
          command: ["/bin/sh", "-c"]
          args:
            - |
              echo '<html><h1>Hello OES</h1></html>' > /usr/share/nginx/html/index.html
              exec nginx -g 'daemon off;'
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
---
apiVersion: projectcontour.io/v1
kind: HTTPProxy
metadata:
  name: hello-proxy
spec:
  virtualhost:
    fqdn: hello.local
  routes:
    - conditions:
        - prefix: /hello
      pathRewritePolicy:
        replacePrefix:
          - prefix: /hello
            replacement: /
      services:
        - name: hello-service
          port: 80
EOF

kubectl create namespace helloapp

kubectl apply --filename hello_deployment.yaml --namespace helloapp
kubectl delete --filename hello_deployment.yaml --namespace helloapp


kubectl get all --namespace helloapp

curl hello-service.helloapp


### Get Nodeport url

kubectl get nodes -o wide
kubectl get services --namespace projectcontour





kubectl patch svc envoy -n projectcontour -p '{"spec":{"externalTrafficPolicy":"Cluster"}}'



```
