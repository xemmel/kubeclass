## Seaweedfs

### Install local-path storageclass (if needed)

```bash

kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml

### Set as default (if needed)
kubectl patch storageclass local-path \
  -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'


```

### Get helm repo

```bash

helm repo add seaweedfs https://seaweedfs.github.io/seaweedfs/helm
helm repo update

```

### Get parameters

```bash 

helm show values seaweedfs/seaweedfs

```

### Install filesystem (no storageclass)

```bash

helm install seaweedfs seaweedfs/seaweedfs \
  --namespace seaweedfs \
  --create-namespace \
  --set s3.enabled=true

```

### Install filesystem (ano)

```bash

helm install seaweedfs seaweedfs/seaweedfs \
  --namespace seaweedfs \
  --create-namespace \
  --set s3.enabled=true \
  --set volume.dataDirs[0].name=data1 \
  --set volume.dataDirs[0].type=persistentVolumeClaim \
  --set volume.dataDirs[0].size=10Gi \
  --set volume.dataDirs[0].storageClass=local-path \
  --set volume.dataDirs[0].maxVolumes=100




```

### Install filesystem (credentials)

> Change accessKey,secretKey etc.

```bash

helm install seaweedfs seaweedfs/seaweedfs \
  --namespace seaweedfs \
  --create-namespace \
  --set s3.enabled=true \
  --set s3.enableAuth=true \
  --set-string s3.credentials.admin.accessKey=customer1 \
  --set-string 's3.credentials.admin.secretKey=5454545454!!!!' \
  --set volume.dataDirs[0].name=data1 \
  --set volume.dataDirs[0].type=persistentVolumeClaim \
  --set volume.dataDirs[0].size=10Gi \
  --set volume.dataDirs[0].storageClass=local-path \
  --set volume.dataDirs[0].maxVolumes=100
 
```

### Get helm parameters 

```bash

helm get values seaweedfs --namespace seaweedfs 

helm get values seaweedfs --namespace seaweedfs --all

```

### Scale volumes

```bash

kubectl scale statefulset --namespace seaweedfs seaweedfs-volume --replicas 2

```


### Test

```bash

kubectl create namespace debug && kubectl run --namespace debug debug  --image nginx


kubectl exec -it --namespace debug debug -- curl seaweedfs-s3.seaweedfs:8333

kubectl exec -n debug debug -- \
  curl -X PUT http://seaweedfs-s3.seaweedfs:8333/mybucket -s

kubectl exec -n debug debug -- \
  sh -c 'printf "testcontent" | curl -s -i -X PUT --data-binary @- http://seaweedfs-s3.seaweedfs:8333/mybucket/file1.txt'

kubectl exec -n debug debug -- \
  curl -s http://seaweedfs-s3.seaweedfs:8333/mybucket/file1.txt



kubectl exec -it --namespace debug debug -- curl http://seaweedfs-s3.seaweedfs.svc.cluster.local:8333


```