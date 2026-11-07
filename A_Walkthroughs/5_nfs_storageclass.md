# NFS

## Create Server

```bash
multipass delete flowgrait-fileshare --purge 2>/dev/null
multipass launch --name flowgrait-fileshare --memory 4GB --cpus 2 --disk 20GB devel
multipass shell flowgrait-fileshare

```

## Install NFS


```bash
sudo apt update
sudo apt upgrade -y
sudo apt install -y nfs-kernel-server

```

## Create the shared directory

```bash
sudo mkdir -p /srv/nfs/flowgrait
sudo chown nobody:nogroup /srv/nfs/flowgrait
sudo chmod 0775 /srv/nfs/flowgrait

```

#### Create the shared directory (Read-only)

```bash
sudo mkdir -p /srv/nfs/flowgrait
sudo chown root:root /srv/nfs/flowgrait
sudo chmod 0755 /srv/nfs/flowgrait

```

### Give full access to all (optional)

```bash
sudo chown nobody:nogroup /srv/nfs/flowgrait
sudo chmod 0777 /srv/nfs/flowgrait

sudo find /srv/nfs/flowgrait -type d -exec chmod 0777 {} +
sudo find /srv/nfs/flowgrait -type f -exec chmod a+rw {} +

``` 

## Input allowed client IP

```bash
read -rp "Kubernetes node IPs (comma-separated): " NODE_IP_INPUT
IFS=',' read -ra NODE_IPS <<< "${NODE_IP_INPUT//[[:space:]]/}"

```

## Configure Client Access

```bash
sudo mkdir -p /etc/exports.d

{
  printf '/srv/nfs/flowgrait'
  for NODE_IP in "${NODE_IPS[@]}"; do
    printf ' %s(rw,sync,no_subtree_check,root_squash)' "$NODE_IP"
  done
  printf '\n'
} | sudo tee /etc/exports.d/flowgrait.exports


```

### Configure Client Access (Read-only)

```bash

sudo mkdir -p /etc/exports.d

{
  printf '/srv/nfs/flowgrait'
  for NODE_IP in "${NODE_IPS[@]}"; do
    printf ' %s(ro,sync,no_subtree_check,root_squash)' "$NODE_IP"
  done
  printf '\n'
} | sudo tee /etc/exports.d/flowgrait.exports


```


## Start the NFS SERVER

```bash

sudo systemctl enable --now nfs-server
sudo exportfs -rav
sudo exportfs -v

```

## FW

### Check

```bash
sudo ufw status

```


### Open client ips

```bash


# Only add rules if UFW is active
if sudo ufw status | grep -q '^Status: active'; then
  for NODE_IP in "${NODE_IPS[@]}"; do
    sudo ufw allow from "$NODE_IP" to any port 2049 proto tcp
  done
fi

```

## Test from Client 

### Enter worker node 

```bash
multipass shell worker1-flowgrait-k8s

```

### Write file on NFS

```bash 

read -rp "NFS server IP: " NFS_SERVER_IP

sudo apt update
sudo apt install -y nfs-common

sudo mkdir -p /mnt/flowgrait
sudo mount -t nfs -o vers=4,rw \
  "${NFS_SERVER_IP}:/srv/nfs/flowgrait" /mnt/flowgrait

echo "Written by $(hostname)" | sudo tee /mnt/flowgrait/test.txt
cat /mnt/flowgrait/test.txt

```

### Tree install

```bash

sudo apt update
sudo apt install tree -y


```

### Tree check

```bash

tree /srv/nfs/flowgrait

```


### Check files on NFS

```bash 

ls -l /srv/nfs/flowgrait
cat /srv/nfs/flowgrait/test.txt

```

### Unmount if needed

```bash 
sudo umount /mnt/flowgrait

```


### Install CSI on K8S

#### Enter Control Plane


```bash
multipass shell control-plane-flowgrait-k8s

```

#### Install 

```bash
helm repo add csi-driver-nfs https://kubernetes-csi.github.io/csi-driver-nfs
helm repo update

helm upgrade --install csi-driver-nfs csi-driver-nfs/csi-driver-nfs \
  --namespace kube-system \
  --wait
  
```
 
#### Verify Installation

```bash
kubectl get pods -n kube-system -o wide | grep csi-nfs
kubectl get csidriver nfs.csi.k8s.io

```
 
 
### Create StorageClass

#### Eager Retain

```bash
read -rp "NFS server IP: " NFS_SERVER_IP

kubectl apply -f - <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: flowgrait-nfs
provisioner: nfs.csi.k8s.io
parameters:
  server: "${NFS_SERVER_IP}"
  share: /srv/nfs/flowgrait
  mountPermissions: "0777"
reclaimPolicy: Retain
volumeBindingMode: Immediate
mountOptions:
  - nfsvers=4
EOF

```

#### Lazy delelte

```bash
read -rp "NFS server IP: " NFS_SERVER_IP

kubectl apply -f - <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: flowgrait-nfs-lazy
provisioner: nfs.csi.k8s.io
parameters:
  server: "${NFS_SERVER_IP}"
  share: /srv/nfs/flowgrait
  mountPermissions: "0777"
  onDelete: delete
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
mountOptions:
  - nfsvers=4
EOF

```

#### Lazy ro

```bash
read -rp "NFS server IP: " NFS_SERVER_IP

kubectl apply -f - <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: flowgrait-nfs-readonly
provisioner: nfs.csi.k8s.io
parameters:
  server: "${NFS_SERVER_IP}"
  share: /srv/nfs/flowgrait
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
mountOptions:
  - nfsvers=4
  - ro
EOF

```

### Create a test PVC

```bash 

kubectl create namespace teststorage

kubectl apply --namespace teststorage -f - <<'EOF'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: flowgrait-nfs-test
spec:
  storageClassName: flowgrait-nfs-lazy
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
EOF

```

### Create elastic with volume

### Create Elastic Deployment/Service

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
  storageClassName: flowgrait-nfs-lazy
  resources:
    requests:
      storage: 1Gi
EOF

kubectl apply --namespace elasticvolume --filename - <<EOF
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

### Log Elastic Pod

```bash

```

### See folder on NFS Server

```bash
ls -la /srv/nfs/flowgrait

```


### Remove PVC

```bash

```

### Remove all

```bash
multipass delete --all --purge

```



