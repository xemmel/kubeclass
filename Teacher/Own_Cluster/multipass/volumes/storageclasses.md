```bash

cat << EOF | tee storageclass-local.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
EOF


```

#### Rancher

```bash

kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.31/deploy/local-path-storage.yaml

```

### Execute

```bash

kubectl apply --filename storageclass-local.yaml

kubectl get storageclasses.storage.k8s.io
```