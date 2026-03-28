## Multipass


### Init

```bash

sudo iptables -P FORWARD ACCEPT


multipass launch --name kube-template --disk 30G --memory 4G --cpus 2

https://github.com/xemmel/kubeclass/tree/master/Teacher/Own_Cluster/multipass

multipass stop kube-template

## multipass snapshot --name kubegroundimage kube-template

```

### Update template

```bash

multipass start kube-template
multipass exec kube-template -- sudo apt update
multipass exec kube-template -- sudo apt upgrade -y
multipass stop kube-template


```

### Create Nodes

```bash

### With client

multipass clone --name con-1-large kube-template
multipass clone --name wor-1-large kube-template
multipass clone --name client-1-large kube-template

multipass start con-1-large wor-1-large client-1-large

### Without client

multipass clone --name con-1-large kube-template
multipass clone --name wor-1-large kube-template

multipass start con-1-large wor-1-large 




```

### Create cluster

```bash


multipass shell con-1-large

sudo apt update && sudo apt upgrade -y

sudo kubeadm init --pod-network-cidr=192.168.0.0/16


		
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# kubectl get nodes

## Completion
sudo apt-get install -y bash-completion
echo "source <(kubectl completion bash)" >> ~/.bashrc
source ~/.bashrc


kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/tigera-operator.yaml

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/custom-resources.yaml


```

#### Worker node

> In **main** terminal

```bash

multipass exec wor-1-large -- sudo apt update
multipass exec wor-1-large -- sudo apt upgrade -y


JOIN_CMD=$(multipass exec con-1-large -- sudo kubeadm token create --print-join-command)
multipass exec wor-1-large -- sudo bash -c "$JOIN_CMD"

multipass exec con-1-large  -- watch kubectl get nodes

```

### Setup users in client

```bash

#### Create client private key

multipass shell client-1-large

sudo apt update && sudo apt upgrade -y

USER="user1"
GROUP="group1"

mkdir usertmp
openssl genrsa -out "./usertmp/$USER.key" 2048

openssl req -new -key "./usertmp/$USER.key" \
  -out "./usertmp/$USER.csr" \
  -subj "/CN=$USER/O=$GROUP"

exit

## User VARS
USER="user1"
GROUP="group1"


multipass transfer -p "client-1-large:/home/ubuntu/usertmp/$USER.csr" "$USER.csr"
multipass transfer -p "$USER.csr" "con-1-large:/home/ubuntu/usertmp/$USER.csr"


rm "$USER.csr"

multipass shell con-1-large

## User VARS
USER="user1"
GROUP="group1"


BASEREQUEST=$(cat ./usertmp/$USER.csr | base64 | tr -d '\n')

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

kubectl get csr

kubectl certificate approve user-csr

kubectl get csr user-csr -o jsonpath='{.status.certificate}' | \
  base64 --decode > ./usertmp/$USER.crt

kubectl delete csr user-csr

kubectl create namespace $USER

kubectl create role $USER-role --verb=* --resource=* --namespace $USER

## For user

kubectl create rolebinding $USER-rolebinding \
  --role="$USER-role" --user=$USER --namespace $USER

## For group

kubectl create rolebinding $GROUP-group-rolebinding \
  --role="$USER-role" --group=$GROUP --namespace $USER

exit


multipass transfer -p "con-1-large:/home/ubuntu/usertmp/$USER.crt" "$USER.crt"
multipass transfer -p "$USER.crt" "client-1-large:/home/ubuntu/usertmp/$USER.crt"


rm "$USER.crt"


multipass exec con-1-large -- kubectl cluster-info

## Copy the url https://[IP-ADDRESS]:[PORT]

multipass shell client-1-large

## Set vars

CONADDRESS="https://10.6.180.130:6443" ## Subject to change

kubectl config set-cluster "test-cluster" \
  --server $CONADDRESS \
  --insecure-skip-tls-verify=true

kubectl config set-credentials $USER \
   --client-certificate=./usertmp/$USER.crt \
   --client-key ./usertmp/$USER.key \
   --embed-certs=true

kubectl config set-context "$USER-context" \
  --cluster="test-cluster" \
  --user=$USER

kubectl config use-context "$USER-context"


```

### Check existing certificate

```bash

kubectl config view --raw -o jsonpath='{.users[0].user.client-certificate-data}' \
| base64 -d \
| openssl x509 -noout -subject -nameopt multiline


```


#### Remove cluster 


```bash

multipass delete con-1-large --purge
multipass delete wor-1-large --purge



```



