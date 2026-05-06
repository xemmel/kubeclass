# curl

## Extract from ./kube/config

```bash

KCFG=~/.kube/config
CTX=$(kubectl config current-context)
CLUSTER=$(kubectl config view -o jsonpath="{.contexts[?(@.name=='$CTX')].context.cluster}")
USER=$(kubectl config view -o jsonpath="{.contexts[?(@.name=='$CTX')].context.user}")

SERVER=$(kubectl config view --raw -o jsonpath="{.clusters[?(@.name=='$CLUSTER')].cluster.server}")
CA=$(kubectl config view --raw -o jsonpath="{.clusters[?(@.name=='$CLUSTER')].cluster.certificate-authority-data}")
CERT=$(kubectl config view --raw -o jsonpath="{.users[?(@.name=='$USER')].user.client-certificate-data}")
KEY=$(kubectl config view --raw -o jsonpath="{.users[?(@.name=='$USER')].user.client-key-data}")

curl -s \
  --cacert <(echo "$CA" | base64 -d) \
  --cert   <(echo "$CERT" | base64 -d) \
  --key    <(echo "$KEY" | base64 -d) \
  "$SERVER/api/v1/namespaces" | jq '.items[].metadata.name'
  


```