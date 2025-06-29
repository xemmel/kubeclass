## Use hardcoded Environment Variables

```powershell

kubectl create namespace configtest
kubectl config set-context --current --namespace configtest


```

- Image: mcr.microsoft.com/azuredocs/aks-helloworld:v1

### Create deployment and service with image

```yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-deployment
spec:
  selector:
    matchLabels:
      app: test
  template:
    metadata:
      labels:
        app: test
    spec:
      containers:
        - name: test-container
          image: mcr.microsoft.com/azuredocs/aks-helloworld:v1
          env:
            - name: TITLE
              value: 'Alternative Title'
---
apiVersion: v1
kind: Service
metadata:
  name: test-service
spec:
  selector:
    app: test
  ports:
    - port: 80
      targetPort: 80

```

## Use config map as Environment Variables

### Deploy config map

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: test-configmap
data:
  webtitle: 'Dynamic Alt Title'

```

### View Configmaps

```powershell

kubectl get cm

```

### Alter deployment

```yaml

- name: TITLE
valueFrom:
    configMapKeyRef:
      name: test-configmap
      key: webtitle

```

