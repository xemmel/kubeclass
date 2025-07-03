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


helm install nfs-sc \
nfs-store/nfs-subdir-external-provisioner \
--set nfs.server=$NFSIP \
--set nfs.path=/k8sdata \
--set storageClass.onDelete=true -n storagenfs \
--create-namespace \
--namespace storagenfs

kubectl get storageclasses.storage.k8s.io

```