### Install NFS Server

```bash

multipass launch --name nfs-1 --disk 20G --memory 2G --cpus 2

multipass exec nfs-1 -- bash -c "sudo apt update && sudo apt upgrade -y"


multipass exec nfs-1 -- bash -c "sudo apt install nfs-kernel-server -y"

multipass exec nfs-1 -- bash -c "sudo mkdir --mode=777 /k8sdata"

multipass exec nfs-1 -- bash -c "echo '/k8sdata *(rw,sync,no_subtree_check)' | sudo tee /etc/exports"

multipass exec nfs-1 -- bash -c "sudo exportfs -a"
multipass exec nfs-1 -- bash -c "sudo exportfs -r"
multipass exec nfs-1 -- bash -c "sudo systemctl restart nfs-kernel-server"

multipass exec nfs-1 -- bash -c "sudo showmount -e localhost"



```

### Install NFS Client on nodes

```bash

NFSIP=$(multipass exec nfs-1 -- bash -c "ip addr | grep -Po '(?<=inet ).*?(?=/2)'")
 
NODE="con-1" ### Change accordingly

multipass exec $NODE -- bash -c "NFSIP='$NFSIP'"
multipass exec $NODE -- bash -c "sudo apt install nfs-common -y"
multipass exec $NODE -- bash -c "showmount -e $NFSIP"

```

### Install NFS provisioner (HELM)

```bash

helm repo add nfs-store https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm repo list

NFSIP=$(nslookup nfs-1 | grep -Po '(?<=Address: ).*?(?=$)')

helm install nfs-sc \
nfs-store/nfs-subdir-external-provisioner \
--set nfs.server=$NFSIP \
--set nfs.path=/k8sdata \
--set storageClass.archiveOnDelete=false \
--namespace storagenfs \
--create-namespace

    kubectl get storageclasses.storage.k8s.io

```

### View folder

```bash
multipass exec nfs-1 -- bash -c "ls /k8sdata"

```


### Test

```bash

kubectl create namespace storageclasstest

cat << EOF >> pvc.yaml

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: sample-nfs-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: nfs-client
  resources:
    requests:
      storage: 2Gi

EOF

kubectl apply --filename pvc.yaml --namespace storageclasstest

kubectl get pv,pvc -A

kubectl delete --filename pvc.yaml --namespace storageclasstest

```


### Elastic full sample

#### full manifest

```yaml

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: elastic-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: nfs-client
  resources:
    requests:
      storage: 2Gi
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
      volumes:
        - name: es-data
          persistentVolumeClaim:
            claimName: elastic-pvc
      containers:
        - name: elastic-container
          image: elasticsearch:9.0.2
          env:
            - name: discovery.type
              value: single-node
            - name: xpack.security.enabled
              value: "false"
          volumeMounts:
            - name: es-data
              mountPath: /usr/share/elasticsearch/data
---
apiVersion: v1
kind: Service
metadata:
  name: elastic-service
spec:
  selector:
    app: elastic
  ports:
    - port: 9200
      targetPort: 9200

```


#### curl in debug pod

```yaml

kubectl exec -it --namespace debug debug -- curl elastic-service.elastic:9200

```