## Gateway api extensions

### Create python application (returns headers) and push it to worker node

```bash

mkdir headersapp
cd headersapp

python3 -m venv dev
source dev/bin/activate
pip install fastapi[standard] uvicorn

cat <<EOF>> app.py
from fastapi import FastAPI, Request

app = FastAPI()

@app.get("/headers")
async def get_headers(request: Request):
    return dict(request.headers)
EOF


cat <<EOF>> Dockerfile
FROM python:3.14-slim

WORKDIR /app

COPY app.py .

RUN pip install --no-cache-dir "fastapi[standard]"

EXPOSE 8000

CMD ["fastapi", "run", "app.py", "--host", "0.0.0.0", "--port", "8000"]
EOF

docker buildx build -t fastapi-headers:1.0 .
docker save fastapi-headers:1.0 -o fastapi-headers-1.0.tar
multipass transfer fastapi-headers-1.0.tar worker1-flowgrait-k8s:/home/ubuntu/
multipass shell worker1-flowgrait-k8s

sudo ctr -n k8s.io images import fastapi-headers-1.0.tar
exit

```

### Deploy the api with a http-route

```bash

kubectl create namespace headers-app

kubectl apply --namespace headers-app -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: headers-app
spec:
  selector:
    matchLabels:
      app: headers-app
  template:
    metadata:
      labels:
        app: headers-app
    spec:
        containers:
        - name: headers-app
          image: fastapi-headers:1.0
---
apiVersion: v1
kind: Service
metadata:
  name: headers-app
spec:
  selector:
    app: headers-app
  ports:
    - name: http
      port: 80
      targetPort: 8000
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: headers-app-httproute
spec:
  parentRefs:
  - name: common-gateway
    namespace: common-gateway
  rules:
    - backendRefs:
      - name: headers-app
        kind: Service
        port: 80
      matches:
        - path:
            type: PathPrefix
            value: /headers
EOF


```

### Test

#### install debug pod

```bash

kubectl create namespace debug
kubectl run --namespace debug debug --image nginx


```

#### Get gateway service internal IP

```bash

kubectl get services --namespace envoy-gateway-system | grep -i load

```

#### exec into debug pod

```bash

kubectl exec -it --namespace debug debug -- bash

```

#### install jq and call /headers

##### install
```bash
apt update
apt install jq -y

```
##### call /headers
> ip may differ

```bash

curl https://10.108.106.17/headers --insecure | jq .

```

### install ClientTrafficPolicy

```bash

kubectl apply --namespace common-gateway --filename - <<EOF
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: ClientTrafficPolicy
metadata:
  name: gateway-request-headers
spec:
  targetRefs:
    - group: gateway.networking.k8s.io
      kind: Gateway
      name: common-gateway
  headers:
    earlyRequestHeaders:
      set:
        - name: X-Forwarded-Proto
          value: https
        - name: test1
          value: value1
        - name: test2
          value: value2
EOF

```

> Run the curl command again inside your *debug* pod