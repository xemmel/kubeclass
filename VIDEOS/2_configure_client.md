# Configure Client Server

## Find the cluster admin role for kubeadmin

```bash

### get all clusterrolebindings with the word "admin"

kubectl get clusterrolebindings.rbac.authorization.k8s.io | grep -i admin

### examine the crb kubeadm:cluster-admins

kubectl describe clusterrolebindings.rbac.authorization.k8s.io kubeadm:cluster-admins

### shows Group  kubeadm:cluster-admins
### So the kubeadmin user will create a Certificate Request with O=kubeadm:cluster-admins in subject

### shows Kind: ClusterRole, Name: cluster-admin

kubectl describe ClusterRole cluster-admin

### Shows *.* * 
### In other words: Can you EVERYTHING


```

## Create User Private Key and Certificate Request

### Enter Client Server

```bash

multipass shell client-flowgrait-k8s

```

### Create two users

```bash

#### Developer

sudo useradd --create-home developer
echo -e "1234\n1234" | sudo passwd developer
sudo chsh -s /bin/bash developer


sudo useradd --create-home kubeadmin
echo -e "1234\n1234" | sudo passwd kubeadmin
sudo chsh -s /bin/bash kubeadmin


```

### Login as user

```bash
su - developer

## OR
su - kubeadmin

```

### Create private key and certificate request

```bash

su - developer

mkdir cert

openssl genrsa -out "./cert/developer.key" 2048

### Create Certificate Signing Request (Developer)
openssl req -new -key "./cert/developer.key" \
  -out "./cert/developer.csr" \
  -subj "/CN=customdeveloper/O=customdevelopers"

cp ./cert/developer.csr /tmp/developer.csr

exit

su - kubeadmin

mkdir cert

openssl genrsa -out "./cert/kubeadmin.key" 2048

### Create Certificate Signing Request (ADMIN)
openssl req -new -key "./cert/kubeadmin.key" \
  -out "./cert/kubeadmin.csr" \
  -subj "/CN=customkubeadmin/O=kubeadm:cluster-admins"

cp ./cert/kubeadmin.csr /tmp/kubeadmin.csr

exit

```

### Copy both csr's to control-plane

```bash

multipass transfer -p client-flowgrait-k8s:/tmp/developer.csr - \
| multipass transfer -p - control-plane-flowgrait-k8s:/tmp/developer.csr

multipass transfer -p client-flowgrait-k8s:/tmp/kubeadmin.csr - \
| multipass transfer -p - control-plane-flowgrait-k8s:/tmp/kubeadmin.csr

```

### Create Certificates for both users using kubectl and native

```bash

multipass shell control-plane-flowgrait-k8s

### Check what subjects the users gave themself

cat /tmp/developer.csr | openssl req -noout -subject
cat /tmp/kubeadmin.csr | openssl req -noout -subject

### Developer

BASEREQUEST=$(cat /tmp/developer.csr | base64 | tr -d '\n')

kubectl apply -f - <<EOF
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: user-csr
spec: 
  request: $BASEREQUEST
  signerName: kubernetes.io/kube-apiserver-client
  usages:
    - client auth
EOF

kubectl certificate approve user-csr

kubectl get csr user-csr -o jsonpath='{.status.certificate}' | \
  base64 --decode > /tmp/developer.crt

kubectl delete csr user-csr

### kubeadmin

sudo openssl x509 -req \
  -in /tmp/kubeadmin.csr \
  -CA /etc/kubernetes/pki/ca.crt \
  -CAkey /etc/kubernetes/pki/ca.key \
  -CAcreateserial \
  -out /tmp/kubeadmin.crt \
  -days 365


```

### Create a namespace for the developer and give him/her full access to that namespace only

```bash

kubectl create namespace developer-poc

kubectl create role developer-poc-full-access --verb=* --resource=* --namespace developer-poc

### Grant the role to all valid users members of the group customdevelopers

kubectl create rolebinding developer-poc-full-access-customdevelopers \
  --role=developer-poc-full-access --group=customdevelopers --namespace developer-poc

#### Check 

kubectl auth can-i list pods \
  -n developer-poc \
  --as developer \
  --as-group customdevelopers

exit

multipass exec control-plane-flowgrait-k8s -- kubectl cluster-info

### Take note of base address with port
### https://10.6.180.186:6443

```


### Copy the Certificates to the users home dir

```bash

multipass transfer -p control-plane-flowgrait-k8s:/tmp/developer.crt - | multipass transfer -p - client-flowgrait-k8s:/tmp/developer.crt

multipass transfer -p control-plane-flowgrait-k8s:/tmp/kubeadmin.crt - | multipass transfer -p - client-flowgrait-k8s:/tmp/kubeadmin.crt

``` 

### Setup kubectl for both users


```bash

multipass shell client-flowgrait-k8s

su - developer

CLUSTER_BASE_ADDRESS="https://10.6.180.186:6443"  ### Replace as needed

## Setup the cluster info

### No ca.crt (insecure MITM attacks!!!)

kubectl config set-cluster "company-cluster" \
  --server="$CLUSTER_BASE_ADDRESS" \
  --insecure-skip-tls-verify=true

### Requires the ca.crt from control-plane, prefered for production
### But depends on if you "trust your channel"


### OR THIS NOT BOTH
kubectl config set-cluster "company-cluster" \
  --server="$CLUSTER_BASE_ADDRESS" \
  --certificate-authority=/tmp/ca.crt \
  --embed-certs=true

### Check the .kube directory and config file that was created
cat ./.kube/config

kubectl config set-credentials currentuser \
   --client-certificate=/tmp/developer.crt \
   --client-key ./cert/developer.key \
   --embed-certs=true

kubectl config set-context company \
  --cluster="company-cluster" \
  --user=currentuser

kubectl config use-context company

### Test

kubectl get pods --namespace developer-poc
kubectl get pods --namespace default ## Fails

kubectl run debug --image nginx --namespace developer-poc

kubectl exec -it debug --namespace developer-poc -- ls

exit

### kubeadmin

su - kubeadmin

CLUSTER_BASE_ADDRESS="https://10.6.180.186:6443"  ### Replace as needed

### I only show insecure now, look at developer for secure channel

kubectl config set-cluster "company-cluster" \
  --server="$CLUSTER_BASE_ADDRESS" \
  --insecure-skip-tls-verify=true

kubectl config set-credentials currentuser \
   --client-certificate=/tmp/kubeadmin.crt \
   --client-key ./cert/kubeadmin.key \
   --embed-certs=true

kubectl config set-context company \
  --cluster="company-cluster" \
  --user=currentuser

kubectl config use-context company

### Test

kubectl get namespaces

#### I have the power to destroy the developers work

kubectl delete namespace developer-poc

#### Now the developer can work again

#### BUT only if the role and rolebindings are created again as they were namespace bound

kubectl create namespace developer-poc

kubectl create role developer-poc-full-access --verb=* --resource=* --namespace developer-poc

kubectl create rolebinding developer-poc-full-access-customdevelopers \
  --role=developer-poc-full-access --group=customdevelopers --namespace developer-poc


```


### Scratch Client

```bash

multipass delete client-flowgrait-k8s --purge
multipass clone --name client-flowgrait-k8s flowgrait-k8s-template
multipass start client-flowgrait-k8s



```


### Remove users

```bash

sudo deluser developer
sudo rm -rf /home/developer

sudo deluser kubeadmin
sudo rm -rf /home/kubeadmin


```