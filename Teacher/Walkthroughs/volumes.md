## Volumes


### Setup kind volume cluster

```bash

#### Delete existing cluster if needed
EXISTINGCLUSTERNAME=$(kind get clusters)
kind delete cluster --name $EXISTINGCLUSTERNAME


### Create kind cluster manifest file
cat <<EOF>> volume_cluster.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
  extraMounts:
  - hostPath: ./kindvolume
    containerPath: /var/local-path-provisioner
EOF

kind create cluster --name volume --config volume_cluster.yaml


```

[Back to top](#volumes)


### install nginx with volume mount

```bash


cat <<EOF>> pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: webserver-volume-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF


cat <<EOF>> deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webserver-volume-deployment
spec:
  selector:
    matchLabels:
      app: webserver-volume
  template:
    metadata:
      labels:
        app: webserver-volume
    spec:
      containers:
        - name: webserver-volume-container
          image: nginx
          volumeMounts:
          - mountPath: /usr/share/nginx/html
            name: webmount
      volumes:
        - name: webmount
          persistentVolumeClaim:
            claimName: webserver-volume-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: webserver-volume-service
spec:
  selector:
    app: webserver-volume
  ports:
    - port: 80
      targetPort: 80
EOF

kubectl create namespace volume
kubectl config set-context --current --namespace volume

kubectl apply --filename pvc.yaml

kubectl get pv,pvc

kubectl apply --filename deployment.yaml

```


[Back to top](#volumes)

### Test with Debug pod

```bash

kubectl create namespace debug && kubectl run --namespace debug debug --image nginx
sleep 3
kubectl exec -it --namespace debug debug -- bash

curl webserver-volume-service.volume

### Use will see a forbidden since there are no files in the html folder

### The pvc folder name will differ!
echo '<html><h1>hello</h1>' >> kindvolume/pvc-53165656-02e3-4e57-bbf4-c3d985f95687_volume_webserver-volume-pvc/index.html

### Now go back into the debug pod and curl again

```

[Back to top](#volumes)

### Elastic with volume mount


```bash

kubectl create namespace elastic
kubectl config set-context --current --namespace elastic

cat <<EOF>> elastic_pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: elastic-volume-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF


cat <<EOF>> elastic_deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: elastic-volume-deployment
spec:
  selector:
    matchLabels:
      app: elastic-volume
  template:
    metadata:
      labels:
        app: elastic-volume
    spec:
      containers:
        - name: elastic-volume-container
          image: elasticsearch:9.1.5
          env:
            - name: discovery.type
              value: "single-node"
            - name: xpack.security.enabled
              value: "false"
          volumeMounts:
          - mountPath: /usr/share/elasticsearch/data
            name: datamount
      volumes:
        - name: datamount
          persistentVolumeClaim:
            claimName: elastic-volume-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: elastic-volume-service
spec:
  selector:
    app: elastic-volume
  ports:
    - port: 9200
      targetPort: 9200
EOF



kubectl apply --filename elastic_pvc.yaml

kubectl get pv,pvc

kubectl apply --filename elastic_deployment.yaml


### Now test elastic inside the debug pod

kubectl exec -it --namespace debug debug -- bash

curl elastic-volume-service.elastic:9200

### Create an index

curl elastic-volume-service.elastic:9200/db1 -X PUT

### List indices

curl elastic-volume-service.elastic:9200/_cat/indices

### Exit and delete your deployment and re-deploy it

kubectl delete --filename elastic_deployment.yaml

#### Note that the pvc and pv is still there

kubectl get pv,pvc

### Now apply the deployment again

kubectl apply --filename elastic_deployment.yaml

#### Check log until ready

kubectl logs -l app=elastic-volume -f

### Now enter your debug pod again and see that the index (db1) is still there

kubectl exec -it --namespace debug debug -- bash
curl elastic-volume-service.elastic:9200/_cat/indices


```




```

[Back to top](#volumes)
