# Own Identity Provider

## Create IP in docker

```bash

docker run -d   \
    --name keycloak   \
    -p 0.0.0.0:8855:8080   \
    -e KEYCLOAK_ADMIN=admin   \
    -e KEYCLOAK_ADMIN_PASSWORD=admin  \
    -v "$(pwd)/dockerdata/keycloak:/opt/keycloak/data" \
    quay.io/keycloak/keycloak:latest  \
    start-dev --import-realm

```

## Get well-known

```bash

curl http://localhost:8855/realms/master/.well-known/openid-configuration | jq .

```

## Get Token

```bash

CLIENTID="1717"
CLIENTSECRET="nq..."


curl -X POST \
  http://localhost:8855/realms/master/protocol/openid-connect/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials" \
  -d "client_id=$CLIENTID" \
  -d "client_secret=$CLIENTSECRET"


```

### View Token

```bash

TOKEN=$(curl -X POST \
  http://localhost:8855/realms/master/protocol/openid-connect/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials" \
  -d "client_id=$CLIENTID" \
  -d "client_secret=$CLIENTSECRET" \
  -d "scope=openid")

echo $TOKEN | jq .access_token -r | awk -F"." '{ print $2 }' | base64 -d | jq .


```