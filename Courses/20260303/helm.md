## Install helm

```bash

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
chmod 700 get_helm.sh
./get_helm.sh

cat <<EOF>> deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.app.name }}-deployment
spec:
  replicas: {{ .Values.app.replicas }}
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
          image: nginx
EOF




helm install appx-test appx/ --set "app.name=appx" --set "env=test" --namespace appx-test --create-namespace

helm install appx-prod appx/ --set "app.name=appx" --set "env=prod" --namespace appx-prod --create-namespace