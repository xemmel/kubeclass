## seaweedfs POC





### Make servers

multipass stop flowgrait-k8s-template

multipass info worker1-flowgrait-k8s >/dev/null 2>&1 && multipass delete worker1-flowgrait-k8s --purge
multipass info worker2-flowgrait-k8s >/dev/null 2>&1 && multipass delete worker2-flowgrait-k8s --purge

multipass info control-plane-flowgrait-k8s >/dev/null 2>&1 && multipass delete control-plane-flowgrait-k8s --purge

multipass clone --name control-plane-flowgrait-k8s flowgrait-k8s-template
multipass clone --name worker1-flowgrait-k8s flowgrait-k8s-template
multipass clone --name worker2-flowgrait-k8s flowgrait-k8s-template

multipass set local.control-plane-flowgrait-k8s.memory=6G
multipass set local.worker1-flowgrait-k8s.memory=6G
multipass set local.worker2-flowgrait-k8s.memory=6G

multipass start control-plane-flowgrait-k8s worker1-flowgrait-k8s worker2-flowgrait-k8s


### Take snapshot

multipass stop worker1-flowgrait-k8s worker2-flowgrait-k8s control-plane-flowgrait-k8s

multipass info control-plane-flowgrait-k8s.clean >/dev/null 2>&1 && multipass delete control-plane-flowgrait-k8s.clean --purge
multipass info worker1-flowgrait-k8s.clean >/dev/null 2>&1 && multipass delete worker1-flowgrait-k8s.clean --purge
multipass info worker2-flowgrait-k8s.clean >/dev/null 2>&1 && multipass delete worker2-flowgrait-k8s.clean --purge


multipass snapshot --name clean control-plane-flowgrait-k8s
multipass snapshot --name clean worker1-flowgrait-k8s
multipass snapshot --name clean worker2-flowgrait-k8s

multipass start control-plane-flowgrait-k8s worker1-flowgrait-k8s worker2-flowgrait-k8s


### Restore

multipass stop worker1-flowgrait-k8s worker2-flowgrait-k8s control-plane-flowgrait-k8s --force

multipass restore --destructive control-plane-flowgrait-k8s.clean
multipass restore --destructive worker1-flowgrait-k8s.clean
multipass restore --destructive worker2-flowgrait-k8s.clean

multipass start control-plane-flowgrait-k8s worker1-flowgrait-k8s worker2-flowgrait-k8s


### Install seaweedfs

#### Install storageclass

kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml

### Set as default (if needed)
kubectl patch storageclass local-path \
  -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'



#### 


helm repo add seaweedfs https://seaweedfs.github.io/seaweedfs/helm
helm repo update


helm show values seaweedfs/seaweedfs


67:  replicas: 1 (master.replicas)
318:  replicas: 1 (volume.replicas)
359:  # Particularly useful when using more than 1 for the volume server replicas.
593:# them locally—for example, replicas, nodeSelector, dataCenter, etc.
599:#     replicas: 2 (volumes samples)
604:#     replicas: 2
609:#     replicas: 2
620:  replicas: 1 (filer.replicas)
938:  replicas: 1  (s3.replicas)
1131:  replicas: 1 (sftp.replicas)
1207:  replicas: 1 (admin.replicas)
1348:  replicas: 1 (worker.replicas)
1467:  replicas: 1  # Number of replicas (note: multiple replicas may require shared storage) (allInOne.replicas)
1489:  # For multiple replicas with RollingUpdate, you MUST use shared storage


ubuntu@control-plane-flowgrait-k8s:~$ helm show values seaweedfs/seaweedfs | grep -i storageclass -n
117:  #    storageClass: "local-path-provisioner" (master.config.data.storageClass)
131:    storageClass: "" (master.data.storageClass)
139:  #   storageClass: "local-path-provisioner" (master.data.logs.storageClass)
149:    storageClass: "" (master.logs.storageClass)
342:  #     storageClass: "local-path-provisioner" (volume.extraArgs[0].dataDirs[0].storageClass)
372:      #   storageClass: "yourClassNameOfChoice" (volume.dataDirs[0].storageClass)

392:  #  storageClass: "local-path-provisioner" (volume.idx)
673:  # DEPRECATE: enablePVC, storage, storageClass
681:  # storageClass is the class of storage which defaults to null (the Kube cluster will pick the default).
682:  storageClass: null 
688:  #    storageClass: "local-path-provisioner" (filer.data.storageClass) !!
703:    storageClass: "" (filer.data.storageClass) !!
711:  #   storageClass: "local-path-provisioner" (filer.logs.storageClass)
721:    storageClass: ""
1064:    storageClass: ""
1243:    storageClass: ""
1251:    storageClass: ""
1566:    storageClass: null  # Storage class for the PVC (null uses cluster default)


allInOne.replicas=2

allInOne.data.type=persistentVolumeClaim
allInOne.data.size=4Gi
allInOne.data.storageClass=local-path





helm install seaweedfs seaweedfs/seaweedfs \
  --namespace seaweedfs \
  --create-namespace \
  --set s3.enabled=true \
  --set global.seaweedfs.createClusterRole=true \
  --set allInOne.enabled=true \
  --set allInOne.replicas=2 \
  --set allInOne.data.type=persistentVolumeClaim \
  --set allInOne.data.size=4Gi \
  --set allInOne.data.storageClass=local-path



helm install seaweedfs seaweedfs/seaweedfs \
  --namespace seaweedfs \
  --create-namespace \
  --set global.seaweedfs.createClusterRole=true \
  --set master.replicas=1 \
  --set volume.replicas=2 \
  --set filer.replicas=2 \
  --set s3.enabled=true \
  --set s3.replicas=2 \
  --set 'volume.dataDirs[0].name=data1' \
  --set 'volume.dataDirs[0].type=persistentVolumeClaim' \
  --set 'volume.dataDirs[0].storageClass=local-path' \
  --set 'volume.dataDirs[0].size=40Gi' \
  --set 'volume.dataDirs[0].maxVolumes=0' \
  --set filer.data.type=persistentVolumeClaim \
  --set filer.data.storageClass=local-path \
  --set filer.data.size=40Gi






  --set volume.dataDirs[0].name=data1 \
  --set volume.dataDirs[0].type=persistentVolumeClaim \
  --set volume.dataDirs[0].size=10Gi \
  --set volume.dataDirs[0].storageClass=local-path \
  --set volume.dataDirs[0].maxVolumes=100



--set filer.enablePVC=true \
--set filer.storageClass=local-path \



helm repo add seaweedfs https://seaweedfs.github.io/seaweedfs/helm
helm repo update


helm install seaweedfs seaweedfs/seaweedfs \
  --namespace seaweedfs \
  --create-namespace \
  --set s3.enabled=true \
  --set s3.replicas=2 \
  --set volume.replicas=2 \
  --set global.seaweedfs.createClusterRole=false \
  --set volume.dataDirs[0].name=data1 \
  --set volume.dataDirs[0].type=persistentVolumeClaim \
  --set volume.dataDirs[0].size=30Gi \
  --set volume.dataDirs[0].storageClass=local-path \
  --set volume.dataDirs[0].maxVolumes=100


 \
  --set filer.enablePVC=true \
  --set filer.storageClass=local-path


kubectl create namespace debug && kubectl run --namespace debug debug  --image nginx


kubectl exec -n debug debug -- \
  curl -X GET http://seaweedfs-s3.seaweedfs:8333/

kubectl exec -n debug debug -- \
  curl -X PUT http://seaweedfs-s3.seaweedfs:8333/bucket1 -s

kubectl exec -n debug debug -- \
  curl -X PUT http://seaweedfs-s3.seaweedfs:8333/bucket2 -s



kubectl exec -n debug debug -- \
  sh -c 'printf "testcontent" | curl -s -i -X PUT --data-binary @- http://seaweedfs-s3.seaweedfs:8333/bucket1/file1_!.txt'

kubectl exec -n debug debug -- \
  sh -c 'printf "testcontent" | curl -s -i -X PUT --data-binary @- http://seaweedfs-s3.seaweedfs:8333/bucket2/file2_2.txt'


kubectl exec -n debug debug -- \
  sh -c 'printf "testcontent3" | curl -s -i -X PUT --data-binary @- http://seaweedfs-s3.seaweedfs:8333/bucket2/file3_2.txt'


kubectl exec -n debug debug -- \
  sh -c 'printf "testcontent4" | curl -s -i -X PUT --data-binary @- http://seaweedfs-s3.seaweedfs:8333/bucket2/file4_2.txt'

kubectl exec -n debug debug -- \
  sh -c 'printf "testcontent4fdfldfjdsljfsfdsflkjdsflkjdsflkjsdlkjflkjdsflkjdslk" | curl -s -i -X PUT --data-binary @- http://seaweedfs-s3.seaweedfs:8333/bucket2/file5_2.txt'



