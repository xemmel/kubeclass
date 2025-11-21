### HELM


#### Install

```bash

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
chmod 700 get_helm.sh
./get_helm.sh


### Completion
echo "source <(helm completion bash)" >> ~/.bashrc
source ~/.bashrc

```

```bash

CHARTNAME="flowapp"

mkdir $CHARTNAME
cat<<EOF>>$CHARTNAME/Chart.yaml
apiVersion: v2
name: $CHARTNAME
type: application
version: 1.0.0
appVersion: "1.16.0"
EOF

mkdir $CHARTNAME/templates


cat<<EOF>>$CHARTNAME/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.app.name }}-deployment
spec:
  replicas: {{ .Values.replicas }}
  selector:
    matchLabels:
      app: {{ .Values.app.name }}
  template:
    metadata:
      labels:
        app: {{ .Values.app.name }}
    spec:
      containers:
        - name: {{ .Values.app.name }}
          image: {{ .Values.image }}
EOF

cat<<EOF>>$CHARTNAME/templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.app.name }}-service
spec:
  selector:
    app: {{ .Values.app.name }}
  ports:
    - port: {{ .Values.port }}
      targetPort: {{ .Values.port }}
EOF

cat<<EOF>>$CHARTNAME/values.yaml
replicas: 3
port: 80
EOF

```

```bash

APPNAME="flowapp1"

helm install $APPNAME $CHARTNAME/ --set app.name=$APPNAME --set image=nginx --namespace $APPNAME --create-namespace

kubectl get all --namespace $APPNAME

helm upgrade $APPNAME $CHARTNAME/ --set app.name=$APPNAME --set image=nginx  --set replicas=5 --namespace $APPNAME

helm lint $CHARTNAME/ --set app.name=$APPNAME

helm history $APPNAME --namespace $APPNAME
helm rollback $APPNAME 1 --namespace $APPNAME


kubectl create namespace debug && kubectl run debug --namespace debug --image nginx


kubectl exec -it debug --namespace debug -- sh -c "curl $APPNAME-service.$APPNAME"


rm -rf $CHARTNAME
helm uninstall $APPNAME --namespace $APPNAME
kubectl delete namespace $APPNAME


```