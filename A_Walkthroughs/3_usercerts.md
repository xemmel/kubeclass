### User certs

```bash

docker run -d -p 3000:8080 \
    --name open-webui \
    --restart always \
    ghcr.io/open-webui/open-webui:ollama


docker run -d -p 3000:8080 \
    --gpus=all \
    -v ollama:/root/.ollama \
    -v open-webui:/app/backend/data \
    --name open-webui \
    --restart always \
    ghcr.io/open-webui/open-webui:ollama



    docker run -d -p 3000:8080  --name open-webui --restart always ghcr.io/open-webui/open-webui:ollama


```





## Setup kubernetes user

- user creates their own private-key and a certificate request, with the users *name* and *group*

```bash

mkdir user_init

- Create private-key

openssl genrsa -out "./user_init/user.key" 2048

- Create Certificate Signing Request

openssl req -new -key "./user_init/user.key" \
  -out "./user_init/user.csr" \
  -subj "/CN=user1/O=developers"


- Copy csr into control plane (multipass)

cat ./user_init/user.csr | multipass transfer -p - control-plane-flowgrait-k8s:/tmp/user.csr


- Inside control plane, sign the csr with the clusters

  - Check the subject/org (user/group)
  cat /tmp/user.csr | openssl req -noout -subject

- Sign it with openssl

sudo openssl x509 -req \
  -in /tmp/user.csr \
  -CA /etc/kubernetes/pki/ca.crt \
  -CAkey /etc/kubernetes/pki/ca.key \
  -CAcreateserial \
  -out /tmp/user.crt \
  -days 365


- Sign it with kubectl

BASEREQUEST=$(cat /tmp/user.csr | base64 | tr -d '\n')

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
  base64 --decode > /tmp/user_kube.crt

kubectl delete csr user-csr


- Check newly created user certificate

cat /tmp/user.crt | openssl x509 -noout -subject -issuer -dates

- Get the API-Server address and port and take a note of it

kubectl cluster-info | grep -oP "(?<=plane is running at ).*?(?=$)"


- On client server get the .crt from the control plane (multipass)

multipass exec control-plane-flowgrait-k8s -- cat /tmp/user.crt | tee user_init/user.crt > /dev/null


- Curl the endpoint raw (insecure)

curl https://[API-Endpoint] --insecure

- Let's fix the insecure TLS problem. Get the API-Server certificate from the control-plane

```

```bash

multipass exec control-plane-flowgrait-k8s -- cat /etc/kubernetes/pki/ca.crt | tee user_init/kube_ca.crt > /dev/null


curl https://[API-Endpoint] --cacert user_init/kube_ca.crt

- We now have a secure TLS channel towards the control plane API Server

- Notice it keeps saying "anonymous", that is because we are not supplying the newly created user certificate

curl https://[API-Endpoint] --cacert user_init/kube_ca.crt --cert user_init/user.crt --key user_init/user.key

- Returns something with forbidden/user1, so now we ARE authenticated but not authorized to do anything inside the cluster

- Back in the control plane, we create a namespace *developers-playground* and give the group **developers** full access to that namespace

kubectl create namespace developers-playground

## Check if user1 (being user1 and member of the group *developers*) can list pods inside the namespace

kubectl auth can-i list pods \
  -n developers-playground \
  --as user1 \
  --as-group developers

- **no** since we have not made any *roles* or *rolebindings* yet

## Create the role that allows for all (verbs/nouns) inside this namespace

kubectl create role developers-playground-full-access --verb=* --resource=* --namespace developers-playground

## Create the rolebinding that binds the role to the group (developers)

kubectl create rolebinding developers-playground-full-access-group-developers \
  --role=developers-playground-full-access --group=developers --namespace developers-playground

- Now as a good administrator you ALWAYS check yourself because contacting the user and saying "It should work now", right?? :-)

kubectl auth can-i list pods \
  -n developers-playground \
  --as user1 \
  --as-group developers

**yes**

- Now we can try again on the client machine


curl https://[API-Endpoint] --cacert user_init/kube_ca.crt --cert user_init/user.crt --key user_init/user.key

- Still *forbidden* we are still trying to access some global cluster stuff (/)

- Now try to list all pods in the *developers-playground* namespace


curl https://[API-Endpoint]/api/v1/namespaces/developers-playground/pods --cacert user_init/kube_ca.crt --cert user_init/user.crt --key user_init/user.key


returns

```

```json
{
  "items" : []
}

```

- Now of course the user, most likely, do not want to do all the work towards the API Server with raw HTTP commands, so let's configure kubectl


- Install kubectl (if not already installed)

## Check if installed

which kubectl

```bash

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

chmod +x kubectl
mkdir -p ~/.local/bin
mv ./kubectl ~/.local/bin/kubectl

### kubectl completion

sudo apt-get install -y bash-completion
echo "source <(kubectl completion bash)" >> ~/.bashrc
source ~/.bashrc

```

- Setup Cluster, user and context on kubectl

CLUSTER_BASE_ADDRESS="[API-Endpoint]" ### The same *ADDRESS* AND *PORT* used in the curl commands before syntax: **https://[ADDRESS]:[PORT]

> change names accordingly

kubectl config set-cluster "develop-cluster" \
  --server="$CLUSTER_BASE_ADDRESS" \
  --certificate-authority=./user_init/kube_ca.crt \
  --embed-certs=true

kubectl config set-credentials user1 \
   --client-certificate=./user_init/user.crt \
   --client-key ./user_init/user.key \
   --embed-certs=true

kubectl config set-context develop \
  --cluster="develop-cluster" \
  --user=user1


kubectl config use-context develop


- Test it

kubectl get pods --namespace developers-playground

> No resources found


- Create a pod

kubectl run --namespace developers-playground testpod --image nginx


- Ok this is working now

- If you find out that the *developers* should just have full access to everything in the cluster (being a developer/test cluster maybe?) then inside the control plane

```bash

## Check if user1 can list all namespaces

kubectl auth can-i list namespaces \
  --as user1 \
  --as-group developers


## Cluster bind the group developers to the clusterrole cluster-admin

kubectl create clusterrolebinding developers-playground-full-access \
  --clusterrole=cluster-admin --group=developers

## Now check again

## Cleanup the role/rolebinding create in the namespace

kubectl delete rolebinding developers-playground-full-access-group-developers --namespace developers-playground
kubectl delete role developers-playground-full-access --namespace developers-playground



```







