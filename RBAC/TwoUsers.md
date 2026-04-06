## Two Users

### Setup 

- User1 / Group1 -> Will have full control in namespace **group1** because of *Group Name*
- User2 / Group2 -> Will be able to list pods only because of *User Name*

> Note: We will create a *private key* for both users, normally they will each have there own **Server** and the *private key* will not be shared nor leave their **Server**
```bash

multipass shell client-1-large

sudo apt install tree -y

mkdir user1cred
mkdir user2cred

## Create private keys

openssl genrsa -out "./user1cred/user1.key" 2048
openssl genrsa -out "./user2cred/user2.key" 2048

### Create Certificate Signing Requests
openssl req -new -key "./user1cred/user1.key" \
  -out "./user1cred/user1.csr" \
  -subj "/CN=user1/O=Group1"

openssl req -new -key "./user2cred/user2.key" \
  -out "./user2cred/user2.csr" \
  -subj "/CN=user2/O=Group2"


exit

### Copy csr files to Control-Plane

MULTIUSER=$(multipass exec con-1-large -- whoami)

#### User1
multipass transfer -p "client-1-large:/home/$MULTIUSER/user1cred/user1.csr" "user1.csr"
multipass transfer -p "user1.csr" "con-1-large:/home/$MULTIUSER/user1cred/user1.csr"


#### User2
multipass transfer -p "client-1-large:/home/$MULTIUSER/user2cred/user2.csr" "user2.csr"
multipass transfer -p "user2.csr" "con-1-large:/home/$MULTIUSER/user2cred/user2.csr"



rm user1.csr
rm user2.csr

### Enter control-plane and sign the csr's using the cluster CA and create certificates for each user

multipass shell con-1-large

### User1
REQUESTUSER="user1"
## REQUESTUSER="user2"
BASEREQUEST=$(cat ./${REQUESTUSER}cred/${REQUESTUSER}.csr | base64 | tr -d '\n')

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
  base64 --decode > ./${REQUESTUSER}cred/$REQUESTUSER.crt

kubectl delete csr user-csr

exit

### Copy certificates to client Server and the ca.crt

MULTIUSER=$(multipass exec con-1-large -- whoami)

## Ca (If not running insecure-skip-tls-verify=true)

multipass transfer -p "con-1-large:/etc/kubernetes/pki/ca.crt" "ca.crt"
multipass transfer -p "ca.crt" "client-1-large:/home/$MULTIUSER/ca/ca.crt"


### User1
multipass transfer -p "con-1-large:/home/$MULTIUSER/user1cred/user1.crt" "user1.crt"
multipass transfer -p "user1.crt" "client-1-large:/home/$MULTIUSER/user1cred/user1.crt"

### User2
multipass transfer -p "con-1-large:/home/$MULTIUSER/user2cred/user2.crt" "user2.crt"
multipass transfer -p "user2.crt" "client-1-large:/home/$MULTIUSER/user2cred/user2.crt"


rm "user1.crt"
rm "user2.crt"
rm "ca.crt"


### Setup kubectl for both users on client

### Get the API Server URL (https://[IP-ADDRESS]:[PORT])

multipass exec con-1-large -- kubectl cluster-info

multipass shell client-1-large

CONADDRESS="


## Completion

sudo apt-get install -y bash-completion
echo "source <(kubectl completion bash)" >> ~/.bashrc
source ~/.bashrc


## No ca.crt (insecure MITM attacks!!!)
kubectl config set-cluster "test-cluster" \
  --server $CONADDRESS \
  --insecure-skip-tls-verify=true

## TLS ca.crt

kubectl config set-cluster test-cluster \
  --server="$CONADDRESS" \
  --certificate-authority=./ca/ca.crt \
  --embed-certs=true


kubectl config set-credentials user1 \
   --client-certificate=./user1cred/user1.crt \
   --client-key ./user1cred/user1.key \
   --embed-certs=true

kubectl config set-context "user1-test-context" \
  --cluster="test-cluster" \
  --user=user1


kubectl config set-credentials user2 \
   --client-certificate=./user2cred/user2.crt \
   --client-key ./user2cred/user2.key \
   --embed-certs=true

kubectl config set-context "user2-test-context" \
  --cluster="test-cluster" \
  --user=user2



kubectl config use-context "user1-test-context"
kubectl config use-context "user2-test-context"

kubectl get namespaces


exit

### Give the users RBAC

multipass shell con-1-large

### Give Group: Group1 full control of namespace group1
kubectl create namespace group1

kubectl create role group1-full-control-role --verb=* --resource=* --namespace group1

kubectl create rolebinding group1-group1-full-control-rolebinding \
  --role=group1-full-control-role --group=Group1 --namespace group1

### Give User: User2 the ability to list pods in all namespaces
kubectl create clusterrole list-all-pods --verb=list --resource=pods

kubectl create clusterrolebinding user2-list-all-pods-clusterrolebinding \
  --clusterrole=list-all-pods --user=user2

### Test

kubectl config use-context "user1-test-context"

kubectl get pods -A ## Fails
kubectl get pods,services --namespace group1 ## Succeeds

kubectl config use-context "user2-test-context"

kubectl get pods -A ## Succeeds
kubectl get pods,services --namespace group1 ## Fails

#### Raw curl call using ca.crt and using user1

curl \
  --cacert ca/ca.crt \
  --cert user1cred/user1.crt \
  --key user1cred/user1.key \
  https://10.6.180.251:6443/api/v1/namespaces/group1/pods


## If no ca.crt

curl \
  --insecure \
  --cert user1cred/user1.crt \
  --key user1cred/user1.key \
  https://10.6.180.251:6443/api/v1/namespaces/group1/pods


```

### Check existing certificate

```bash

kubectl config view --raw -o jsonpath='{.users[0].user.client-certificate-data}' \
| base64 -d \
| openssl x509 -noout -subject -nameopt multiline


```