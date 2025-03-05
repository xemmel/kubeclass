```bash
sudo iptables -P FORWARD ACCEPT

rm cp_temp.yaml
cat preflight.yaml > cp_temp.yaml
cat cp.yaml >> cp_temp.yaml


multipass launch --name cp-1 --cloud-init cp_temp.yaml --disk 20G --memory 2G --cpus 2



```
#### Debug

```bash
kubectl create namespace debug
kubectl run debug --image nginx --namespace debug

kubectl exec -it debug --namespace debug -- bash

kubectl exec -it debug --namespace debug -- curl test-service.test01:9200

kubectl exec -it debug --namespace debug -- ping 8.8.8.8

```

```bash

sudo apt install docker.io
sudo docker login --username=xemmel


```

```bash

PASSWORD=...;
kubectl create secret docker-registry regcred --docker-server=https://index.docker.io/v1/ --docker-username=xemmel --docker-password=$PASSWORD --docker-email=lacour@gmail.com --namespace="kube-system"

```

```bash

cat << EOF | tee elastic_deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: test
  template:
    metadata:
      labels:
        app: test
    spec:
      containers:
        - image: elasticsearch:7.17.27
          name: test-container
          env:
            - name: 'discovery.type'
              value: 'single-node'
---
apiVersion: v1
kind: Service
metadata:
  name: test-service
spec:
  selector:
    app: test
  ports:
    - port: 9200
      targetPort: 9200
EOF

```

```bash
cat << EOF | tee cron.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: http-job
spec:
  schedule: "* * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: httpcontainer
              image: curlimages/curl:latest
              command:
                - /bin/sh
                - -c
                - curl https://webhook.site/98ed9b92-772f-414a-a607-487df59b5987
          restartPolicy: OnFailure
EOF
```

### volume

```bash



### Configmap

```bash

cat << EOF | tee configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: test-cm
data:
  thename: Morten
  thekid: Clara4
  thehouse: KOGE
EOF

cat << EOF | tee configmap_env.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: config-test-deployment
spec:
  selector:
    matchLabels:
      app: config-test
  template:
    metadata:
      labels:
        app: config-test
    spec:
      containers:
        - image: nginx
          name: nginx-container
          envFrom:
            - configMapRef:
                name: test-cm
EOF

cat << EOF | tee configmap_folder.yaml
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
EOF

```

### Hello-pod


```bash

kubectl create namespace test01
kubectl config set-context --current --namespace test01

kubectl apply --filename elastic_deployment.yaml


kubectl create namespace cron
kubectl config set-context --current --namespace cron

kubectl apply --filename cron.yaml


kubectl create namespace configmap-test
kubectl config set-context --current --namespace configmap-test

kubectl apply --filename configmap.yaml
kubectl apply --filename configmap_env.yaml
kubectl apply --filename configmap_folder.yaml

kubectl scale deployment config-test-deployment --replicas 3

kubectl exec -it pod/config-test-deployment-c5d5b5cb6-b6v45 -- printenv
kubectl exec -it pod/config-folder-test-deployment-6844bf4fc4-sjjbh -- cat /etc/kuberconfig/thekid

sed 's/Clara4/Clara5/g' configmap.yaml -i
kubectl apply --filename configmap.yaml



```