### Configmap

```yaml

apiVersion: v1
kind: ConfigMap
metadata:
  name: test-config
data:
  title: 'This is my other title'

```

### Env

#### Hardcoded env var in a pod

```yaml

containers:
        - name: test-container
          image: mcr.microsoft.com/azuredocs/aks-helloworld:v1
          env:
            - name: TITLE
              value: thevalue

```

### Env var in pod using config map

```yaml

containers:
        - name: test-container
          image: mcr.microsoft.com/azuredocs/aks-helloworld:v1
          env:
            - name: TITLE
              valueFrom:
                configMapKeyRef:
                  name: test-config
                  key: title

```
