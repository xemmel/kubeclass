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

## Use whole configmap as Env Var

```yaml

apiVersion: v1
kind: ConfigMap
metadata:
  name: test-cm
data:
  TITLE: 'Config Map Title'
  otherkey: othervalue
```

```yaml
          image: mcr.microsoft.com/azuredocs/aks-helloworld:v1
          envFrom:
            - configMapRef:
                name: test-cm

```

## Mount config map to file

> Typically a .conf file

```yaml

apiVersion: v1
kind: ConfigMap
metadata:
  name: test-cm
data:
  TITLE: 'Config Map Title'
  otherkey: othervalue

```

```yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: config-folder-test-deployment
spec:
  selector:
    matchLabels:
      app: config-folder-test
  template:
    metadata:
      labels:
        app: config-folder-test
    spec:
      containers:
        - image: nginx
          name: nginx-container
          volumeMounts:
            - name: configvolume
              mountPath: /etc/kuberconfig
              readOnly: true
      volumes:
        - name: configvolume
          configMap:
            name: test-cm

```