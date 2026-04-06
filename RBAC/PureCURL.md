## Pure CURL

### Multipass setup

```bash

```

### Setup

3 windows
 - con
 - rootserver
 - client 

```bash

## Client

multipass shell client-1-large

sudo apt install tree -y

mkdir user1cred
openssl genrsa -out "./user1cred/user1.key" 2048
openssl req -new -key "./user1cred/user1.key" \
  -out "./user1cred/user1.csr" \
  -subj "/CN=user1/O=Group1"

## Root

### Move user1.key,user2.csr from client to con

multipass transfer "client-1-large:./user1cred/user1.key" "user1.key"
multipass transfer "client-1-large:./user1cred/user1.csr" "user1.csr"

multipass exec con-1-large -- mkdir user1cred

multipass transfer "user1.key" "con-1-large:./user1cred/user1.key"
multipass transfer "user1.csr" "con-1-large:./user1cred/user1.csr"

rm user1.key
rm user1.csr

## Con

multipass shell con-1-large

### Sign the csr with ca.crt and create user1.crt

sudo openssl x509 -req \
  -in ./user1cred/user1.csr \
  -CA /etc/kubernetes/pki/ca.crt \
  -CAkey /etc/kubernetes/pki/ca.key \
  -CAcreateserial \
  -out ./user1cred/user1.crt \
  -days 365
  
## Root

### Move user1.crt, ca.crt from con to client

multipass transfer "con-1-large:./user1cred/user1.crt" "user1.crt"
multipass transfer "user1.crt" "client-1-large:./user1cred/user1.crt"

multipass transfer "con-1-large:/etc/kubernetes/pki/ca.crt" "ca.crt"
multipass transfer "ca.crt" "client-1-large:./user1cred/ca.crt"



rm user1.crt
rm ca.crt

## Client

CONADDRESS=$(getent hosts con-1-large | cut -d" " -f1)
CLUSTERAPIADDRESS="https://${CONADDRESS}:6443"

### Try calling api-server with cert,key and ca
### It will authenticate, but you are not authorized

curl $CLUSTERAPIADDRESS/api/v1/namespaces/group1/pods \
	--cacert ./user1cred/ca.crt \
	--key ./user1cred/user1.key \
	--cert ./user1cred/user1.crt

## con

kubectl create namespace group1

kubectl run --namespace group1 webserver --image nginx

kubectl create role group1-full-control-role --verb=* --resource=* --namespace group1

kubectl create rolebinding group1-group1-full-control-rolebinding \
  --role=group1-full-control-role --group=Group1 --namespace group1


## Client

curl $CLUSTERAPIADDRESS/api/v1/namespaces/group1/pods \
	--cacert ./user1cred/ca.crt \
	--key ./user1cred/user1.key \
	--cert ./user1cred/user1.crt -s \
	|   jq '.items[] | {namespace: .metadata.namespace, name: .metadata.name, containers: .spec.containers[] | {image: .image}}'



```


### Multipass reset

```bash

multipass stop wor-1-large
multipass stop con-1-large

multipass restore --destructive con-1-large.clean
multipass restore --destructive wor-1-large.clean

multipass start con-1-large
multipass start wor-1-large



multipass delete client-1-large --purge
multipass clone --name client-1-large kube-template
multipass start client-1-large

```

### Multipass delete

```bash

multipass delete con-1-large wor-1-large client-1-large

```