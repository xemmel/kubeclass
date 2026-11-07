# NFS

## PRE

### New FileShare Server

```bash
multipass delete flowgrait-fileshare --purge 2>/dev/null
multipass launch --name flowgrait-fileshare --memory 4GB --cpus 2 --disk 20GB devel
multipass shell flowgrait-fileshare

```

### Restore Cluster

```bash
multipass stop worker1-flowgrait-k8s control-plane-flowgrait-k8s --force
multipass restore --destructive control-plane-flowgrait-k8s.clean
multipass restore --destructive worker1-flowgrait-k8s.clean
multipass start control-plane-flowgrait-k8s worker1-flowgrait-k8s
multipass shell control-plane-flowgrait-k8s


```

## Install NFS

### Install the server

```bash
sudo apt update
## sudo apt upgrade -y
sudo apt install -y nfs-kernel-server

```

### Configure

```bash
read -rp "Fileshare name: " NFS_APP_NAME

if [[ ! "$NFS_APP_NAME" =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]*$ ]]; then
  echo "Invalid fileshare name."
else
  path="/srv/nfs/${NFS_APP_NAME}"

  sudo mkdir -p "$path"
  sudo chown nobody:nogroup "$path"

  sudo find "$path" -type d -exec chmod 0777 {} +
  sudo find "$path" -type f -exec chmod a+rw {} +

  while true; do
    read -rp "Allowed IP addresses (comma-separated): " NODE_IP_INPUT
    NODE_IP_INPUT="${NODE_IP_INPUT//[[:space:]]/}"

    if [[ -z "$NODE_IP_INPUT" || "$NODE_IP_INPUT" == ,* ||
          "$NODE_IP_INPUT" == *, || "$NODE_IP_INPUT" == *,,* ]]; then
      echo "Enter one or more IPs separated by commas, without empty entries."
      continue
    fi

    IFS=',' read -ra NODE_IPS <<< "$NODE_IP_INPUT"
    break
  done

  sudo mkdir -p /etc/exports.d

  {
    printf '%s' "$path"
    for NODE_IP in "${NODE_IPS[@]}"; do
      printf ' %s(rw,sync,no_subtree_check,no_root_squash)' "$NODE_IP"
    done
    printf '\n'
  } | sudo tee "/etc/exports.d/${NFS_APP_NAME}.exports"
fi

```

#### Update allowed ip addresses

```bash
read -rp "Fileshare name: " NFS_APP_NAME

if [[ ! "$NFS_APP_NAME" =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]*$ ]]; then
  echo "Invalid fileshare name."
elif [[ ! -f "/etc/exports.d/${NFS_APP_NAME}.exports" ]]; then
  echo "Export configuration does not exist."
else
  path="/srv/nfs/${NFS_APP_NAME}"

  while true; do
    read -rp "Complete allowed IP list (comma-separated): " NODE_IP_INPUT
    NODE_IP_INPUT="${NODE_IP_INPUT//[[:space:]]/}"

    if [[ -z "$NODE_IP_INPUT" || "$NODE_IP_INPUT" == ,* ||
          "$NODE_IP_INPUT" == *, || "$NODE_IP_INPUT" == *,,* ]]; then
      echo "Enter one or more IPs separated by commas, without empty entries."
      continue
    fi

    IFS=',' read -ra NODE_IPS <<< "$NODE_IP_INPUT"
    break
  done

  {
    printf '%s' "$path"
    for NODE_IP in "${NODE_IPS[@]}"; do
      printf ' %s(rw,sync,no_subtree_check,no_root_squash)' "$NODE_IP"
    done
    printf '\n'
  } | sudo tee "/etc/exports.d/${NFS_APP_NAME}.exports"

  sudo exportfs -rav
  sudo exportfs -v
fi
```

### Start the NFS Server

```bash
sudo systemctl enable --now nfs-kernel-server
sudo exportfs -rav
sudo exportfs -v
sudo systemctl status nfs-kernel-server --no-pager

```

### Install tree and list files in share

#### Install

```bash
sudo apt install tree -y

```

#### list files

```bash
tree $path

```

### Test port connection (On a k8s node)

#### Init 

> hostname -I on the NFS Server to get the ip-adress

```bash
read -p "NFS IP: " NFS_IP
read -p "Fileshare name: " NFS_APP_NAME

```

#### Check for open port 2049

```bash
nc -vz $NFS_IP 2049

```


#### Write files

```bash
sudo apt update
sudo apt install -y nfs-common

sudo mkdir -p "/mnt/${NFS_APP_NAME}"
sudo mount -t nfs $NFS_IP:/srv/nfs/${NFS_APP_NAME} /mnt/${NFS_APP_NAME}

echo "Hello from node" | sudo tee /mnt/${NFS_APP_NAME}/message.txt
cat /mnt/${NFS_APP_NAME}/message.txt

```



## Kubernetes NFS StorageClass

### Install the CSIDriver

```bash
helm repo add csi-driver-nfs https://kubernetes-csi.github.io/csi-driver-nfs
helm repo update

helm upgrade --install csi-driver-nfs csi-driver-nfs/csi-driver-nfs \
  --namespace kube-system \
  --wait
 
```

### Install StorageClass

#### Init

```bash
read -p "NFS IP: " NFS_IP
read -p "Fileshare name: " NFS_APP_NAME

```

#### Read-Write Lazy Delete

```bash
kubectl apply -f - <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs-rw-${NFS_APP_NAME}
provisioner: nfs.csi.k8s.io
parameters:
  server: "${NFS_IP}"
  share: /srv/nfs/${NFS_APP_NAME}
  mountPermissions: "0777"
  onDelete: delete
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
mountOptions:
  - nfsvers=4
  - lookupcache=positive
EOF

```


### Test Application with readonly option and able to scale

```bash
kubectl create namespace volumetest

kubectl apply --namespace volumetest --filename - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: volumetest-pvc
spec:
  storageClassName: nfs-rw-${NFS_APP_NAME}
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: volumetest
spec:
  replicas: 1
  selector:
    matchLabels:
      app: volumetest
  template:
    metadata:
      labels:
        app: volumetest
    spec:
      containers:
        - name: nginx
          image: nginx
          ports:
            - containerPort: 80
          volumeMounts:
            - name: content
              mountPath: /usr/share/nginx/html
              readOnly: true
      volumes:
        - name: content
          persistentVolumeClaim:
            claimName: volumetest-pvc
            readOnly: true
---
apiVersion: v1
kind: Service
metadata:
  name: volumetest
spec:
  selector:
    app: volumetest
  ports:
    - port: 80
      targetPort: 80
  type: ClusterIP
EOF

```

### Test

#### Install debug pod

```bash
kubectl create namespace debug
kubectl run --namespace debug debug --image nginx

```

#### run curl

```bash
kubectl exec -it --namespace debug debug -- curl volumetest.volumetest

``` 

#### Write dummy file to fileshare

```bash
PVC_FOLDER=$(find "/srv/nfs/${NFS_APP_NAME}" \
  -mindepth 1 -maxdepth 1 -type d -name 'pvc-*')

echo "<html><body><h1>hello</h1></body></html>" | tee "${PVC_FOLDER}/index.html"

```

#### Scale

```bash
kubectl scale deployment --namespace volumetest volumetest --replicas 3

```


### Elastic Deployment

```bash
kubectl create namespace elasticvolume

kubectl apply --namespace elasticvolume --filename - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: elastic-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: nfs-rw-${NFS_APP_NAME}
  resources:
    requests:
      storage: 1Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: elastic-deployment
spec:
  selector:
    matchLabels:
      app: elastic
  template:
    metadata:
      labels:
        app: elastic
    spec:
      containers:
        - name: elastic-container
          image: elasticsearch:9.1.5
          env:
            - name: 'xpack.security.enabled'
              value: 'false'
            - name: 'discovery.type'
              value: 'single-node'
            - name: ES_JAVA_OPTS
              value: "-Xms512m -Xmx512m"
          resources:
            requests:
                memory: "1Gi"
                cpu: "250m"
            limits:
                memory: "1Gi"
                cpu: "1"
          volumeMounts:
            - mountPath: /usr/share/elasticsearch/data
              name: datamount
      volumes:
        - name: datamount
          persistentVolumeClaim:
            claimName: elastic-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: elastic-service
spec:
  type: NodePort
  selector:
    app: elastic
  ports:
    - port: 9200
      targetPort: 9200
EOF

```

#### Logs

```bash
kubectl logs --namespace elasticvolume -l app=elastic -f

```

#### Test 

```bash
kubectl exec -it --namespace debug debug -- curl elastic-service.elasticvolume:9200

```

#### List indicies

```bash
kubectl exec -it --namespace debug debug -- curl elastic-service.elasticvolume:9200/_cat/indices

```

#### Create index

```bash
kubectl exec -it --namespace debug debug -- curl -X PUT elastic-service.elasticvolume:9200/database1

```

#### Rollout restart

```bash
kubectl rollout restart deployment --namespace elasticvolume elastic-deployment

```
