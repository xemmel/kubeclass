```bash
cat << EOF | tee helloworld_podname_deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-pod-deployment
spec:
  selector:
    matchLabels:
      app: hello-pod
  template:
    metadata:
      labels:
        app: hello-pod
    spec:
      containers:
        - name: hello-pod-container
          image: mcr.microsoft.com/azuredocs/aks-helloworld:v1
          env:
            - name: TITLE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
---
apiVersion: v1
kind: Service
metadata:
  name: hello-pod-service
spec:
  selector:
    app: hello-pod
  ports:
    - port: 80
      name: main        
EOF

```

#### Execute

```bash

kubectl create namespace hello-pod
kubectl config set-context --current --namespace hello-pod
kubectl apply --filename helloworld_podname_deployment.yaml

kubectl scale deployment hello-pod-deployment --replicas 3

kubectl describe service hello-pod-service
watch kubectl describe service hello-pod-service


kubectl exec -it debug --namespace debug -- curl hello-pod-service.hello-pod


kubectl autoscale deployment/hello-pod-deployment --min=1 --max=3 --dry-run=server -o yaml


```