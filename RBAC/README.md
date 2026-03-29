## RBAC

### Setup user cert

#### With multipass 


##### Setup client Server

```bash

multipass clone --name client-1-large kube-template
multipass start client-1-large
multipass exec client-1-large -- sudo apt update
multipass exec client-1-large -- sudo apt upgrade -y


```
##### Setup Vars

```bash

K8SUSER="user1"
K8SGROUP="group1"

```

##### Create private key and certrequest on Client Server

```bash

multipass shell client-1-large

## Setup Vars

### Create private key

mkdir usertmp
openssl genrsa -out "./usertmp/$K8SUSER.key" 2048

### Create Certificate Signing Request
openssl req -new -key "./usertmp/$K8SUSER.key" \
  -out "./usertmp/$K8SUSER.csr" \
  -subj "/CN=$K8SUSER/O=$K8SGROUP"

exit

```

##### Move CSR (Request) to Control Plane

```bash

## Setup Vars

multipass transfer -p "client-1-large:/home/ubuntu/usertmp/$K8SUSER.csr" "$K8SUSER.csr"
multipass transfer -p "$K8SUSER.csr" "con-1-large:/home/ubuntu/usertmp/$K8SUSER.csr"

rm "$K8SUSER.csr"

```

#### Sign the CSR

```bash

multipass shell con-1-large

## Setup vars

BASEREQUEST=$(cat ./usertmp/$K8SUSER.csr | base64 | tr -d '\n')

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
  base64 --decode > ./usertmp/$K8SUSER.crt

kubectl delete csr user-csr

```

##### Copy Signed Certificate back to the Client Server

```bash

multipass transfer -p "con-1-large:/home/ubuntu/usertmp/$K8SUSER.crt" "$K8SUSER.crt"
multipass transfer -p "$K8SUSER.crt" "client-1-large:/home/ubuntu/usertmp/$K8SUSER.crt"


rm "$K8SUSER.crt"


```

##### Setup kubectl with certifate on Client Server

```bash

### Get the API Server URL (https://[IP-ADDRESS]:[PORT])

multipass exec con-1-large -- kubectl cluster-info

multipass shell client-1-large

### Setup vars

## Paste API Server URL into string
CONADDRESS=""

kubectl config set-cluster "test-cluster" \
  --server $CONADDRESS \
  --insecure-skip-tls-verify=true
  

kubectl config set-credentials $K8SUSER \
   --client-certificate=./usertmp/$K8SUSER.crt \
   --client-key ./usertmp/$K8SUSER.key \
   --embed-certs=true

kubectl config set-context "$K8SUSER-context" \
  --cluster="test-cluster" \
  --user=$K8SUSER

kubectl config use-context "$K8SUSER-context"


```

##### Setup RBAC for user or group (Single namespace)

```bash

kubectl create namespace $K8SUSER


### Role that can do anything within a single namespace

kubectl create role $K8SUSER-role --verb=* --resource=* --namespace $K8SUSER

## For single user

kubectl create rolebinding $K8SUSER-rolebinding \
  --role="$K8SUSER-role" --user=$K8SUSER --namespace $K8SUSER

## For group (recommended)

kubectl create rolebinding $K8SGROUP-group-rolebinding \
  --role="$K8SUSER-role" --group=$K8SGROUP --namespace $K8SUSER


```

#### Call raw

```bash

kubectl get pods --namespace $K8SUSER -v7


cat /home/ubuntu/.kube/config

curl https://10.6.180.250:6443/api/v1/namespaces/user1/pods --cert ./usertmp/user1.crt --key ./usertmp/user1.key -k | jq .

```

