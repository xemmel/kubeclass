## Helm


[Back to top](#helm)

### Install helm

```bash

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
chmod 700 get_helm.sh
./get_helm.sh


```

[Back to top](#helm)

### Create Chart

```bash

mkdir helm && cd helm

mkdir -p webchart/templates

cat <<EOF>> webchart/Chart.yaml
apiVersion: v2
name: webchart
version: 1.5.0
EOF

cat <<EOF>> webchart/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.app.name }}-deployment
spec:
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
          env:
            - name: THEVERSION
              value: {{ .Values.theversion }}
EOF


cat <<EOF>> webchart/templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.app.name }}-service
spec:
  selector:
    app: {{ .Values.app.name }}
  ports:
    - port: 80
      targetPort: 80
EOF

helm install webapp1 ./webchart --set app.name=webapp1 --set theversion=111 --namespace webapp1 --create-namespace 

kubectl get all --namespace webapp1


helm install webapp2 ./webchart --set app.name=webapp1 --set theversion=222 --namespace webapp2 --create-namespace 

kubectl get pods -A

### Use theversion env

kubectl exec -it -n webapp1 webapp1-deployment-cb4675f4f-jqsqh -- sh -c \
'printf "%s\n" "<html><body>Version: \${THEVERSION}</body></html>" > /usr/share/nginx/html/index.html'

### Debug pod and test a call to webapp1


helm uninstall webapp1 --namespace webapp1
helm uninstall webapp2 --namespace webapp2

rm -rf webchart





```

[Back to top](#helm)

