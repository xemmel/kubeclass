# Own Identity Provider

## Create IP in docker

```bash

docker run -d   \
    --name keycloak   \
    -p 0.0.0.0:8855:8080   \
    -e KC_BOOTSTRAP_ADMIN_USERNAME=admin   \
    -e KC_BOOTSTRAP_ADMIN_PASSWORD=admin  \
    -v "$(pwd)/dockerdata/keycloak:/opt/keycloak/data" \
    quay.io/keycloak/keycloak:latest  \
    start-dev \
    --import-realm

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



MIIElzCCAn8CBgGec9fIXTANBgkqhkiG9w0BAQsFADAPMQ0wCwYDVQQDDAQxNzE3MB4XDTI2MDUyOTEzMDQ0MVoXDTI5MDUyOTEzMDYyMFowDzENMAsGA1UEAwwEMTcxNzCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAOQwIkG0bYo2A1Bzejxqxo3x5inYck9QAVrfDRKgrEKQab17buXJKxpSI2XZcCe3PWWfJsxUKsRvO0zLWwjoa4QOy+vwF+/8CZRoiAuBG/rcvtz3zb9+TCRzjykVkDrQkkss+GOcFa6EKuaKf9COEsrG6Fe2sfIdh0HvpPqAtCZwW8yIHup2QfKYmaFUDqN3o0hh16fMbDlgUCGJuqmO+SqmKt9a9nnbsylQlU0uh7Gja2/sTdQibp1AZI+kSvl9vRn8guWNKknD3qWd3xXl8QNagPSFuyt9AdYBuTiZb8ygctmNvIe29LBSD1Z4FywwV4cmPRlWpKOnv47qATCZG3dOEPFV3wKThLyL54tMi43SwmyQhW7atoPeoSf8HeCE6HUGxUDlhRYRS9xsssbUe37sQljauljNN/jg4YFmGeldHXWbSyDa1vBi9gKESpmGsVwHOA0zlxPHbIcUZBNR77POQr2kzNmqlb63xSWyHQoC/+VKQsOm0Z9A8HH/P4i8qsf/ipArWiwPC9BsLW+x8kPyGlcaJZTUG2CtFvYVZkHaENc3b6ky8J1PpO/LBKUjXfkqrlEAHr1NH5SHPc3OJYNO7bxzIf5Bvjxc4qZBS95LWY28wOlqnqOyrZhb96rPbzFmHRh/uNNpV4wHFPNiRH5jMzI8xuGxcPtNez2rMKcHAgMBAAEwDQYJKoZIhvcNAQELBQADggIBAJw4x8/djODRRqZ5Tg+aKFoZ1Pu472SjWD3sfyaSpzD+BOClj9cM5dSF+o8B+K+jhdzbb9E3G5t0XqroQbvjYINrGenAAgorjIgtuEcHgcM3Ag+S+Fr7+FusJVOr1XZ7okVcyCV0PPzmfh1oRAS5JiNGsymSGH+5/RkSrUPFjwSZMJ2S2nTFMhIrM1igIgSPcXI51aJNc/OY+i7+887+idatDm7i1+WTQSe3Ri2jP5AS2+uFx3XOba6XfYAu2x4AsGFCY7txyHf1yuQd+iNT8I78vaWRf/ad/6DDEUygtkrFtwu+fxVzv4J0+W0FCY1QiBA6AUkXTL5FZZ1uBmhrdWpFy8T7jSgLG0gOkLDm50Kur9YyJSxPrCixEZQ4YcjjsB2msIF8NsR8F2XXbIlczRZICQIHeD8so40FhZJmZZ1LWlY7bEiZz84Dwgr/o+Hw2FCO6eXurXjeVcceTidEv6IgjfMizkCPvuW4ACQFQd6ZaV1lbRar6+uXs56agY3xxEMiRuvGeyVsazNxOndenGxvg9u8hR6SCourMxrA5BP3aOpocgs8oqRawTz2iBU8SjblKJa0p5TMBP75nzttobGGKYA4FNtXFe0IQu0/cNqo3h3h2Prha7MnhIBwNmxh0Dp2hWuzLw2zXHHQqqsZKJAzGIazBHjJZn1CPEFMMYG2


CLIENTID="1717"
CLIENTSECRET="8Fg88HjzBSKn3S3Guz6SEcK7MDk0D1bD"


curl -X POST \
  http://localhost:8855/realms/master/protocol/openid-connect/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials" \
  -d "client_id=$CLIENTID" \
  -d "client_secret=$CLIENTSECRET" \
  -d "scope=openid"



ADMIN_TOKEN=$(curl -s \
  -d "client_id=admin-cli" \
  -d "username=admin" \
  -d "password=admin" \
  -d "grant_type=password" \
  http://localhost:8855/realms/master/protocol/openid-connect/token \
| jq -r .access_token)


curl -s \
  -H "Authorization: Bearer $TOKEN" \
  http://localhost:8855/admin/realms/master \
| jq '.accessTokenLifespan'


curl -s -X PUT \
  http://localhost:8855/admin/realms/master \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "accessTokenLifespan": 300
  }'


curl -s \
  -H "Authorization: Bearer $TOKEN" \
  http://localhost:8855/admin/realms/master/users | jq .





curl -s \
  -d "client_id=admin-cli" \
  -d "username=admin" \
  -d "password=admin" \
  -d "grant_type=password" \
  http://localhost:8855/realms/master/protocol/openid-connect/token


curl -s \
  -d "client_id=admin-cli" \
  -d "username=user1" \
  -d "password=123" \
  -d "grant_type=password" \
  http://localhost:8855/realms/master/protocol/openid-connect/token


BASE=http://localhost:8855
REALM=master

ADMIN_TOKEN=$(curl -s \
  -d "client_id=admin-cli" \
  -d "username=admin" \
  -d "password=admin" \
  -d "grant_type=password" \
  "$BASE/realms/master/protocol/openid-connect/token" \
| jq -r .access_token)


USERNAME=user2
PASSWORD=123

curl -s -X POST "$BASE/admin/realms/$REALM/users" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"username\": \"$USERNAME\",
    \"enabled\": true
  }"

USER_ID=$(curl -s "$BASE/admin/realms/$REALM/users?username=$USERNAME" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
| jq -r '.[0].id')

curl -s -X PUT "$BASE/admin/realms/$REALM/users/$USER_ID/reset-password" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"type\": \"password\",
    \"temporary\": false,
    \"value\": \"$PASSWORD\"
  }"


  CLIENT_ID=my-client
REDIRECT_URI=http://localhost:3000/*

curl -s -X POST "$BASE/admin/realms/$REALM/clients" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"clientId\": \"$CLIENT_ID\",
    \"enabled\": true,
    \"protocol\": \"openid-connect\",
    \"publicClient\": false,
    \"standardFlowEnabled\": true,
    \"directAccessGrantsEnabled\": true,
    \"serviceAccountsEnabled\": true,
    \"redirectUris\": [\"$REDIRECT_URI\"]
  }"


  KC_CLIENT_UUID=$(curl -s "$BASE/admin/realms/$REALM/clients?clientId=$CLIENT_ID" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
| jq -r '.[0].id')


CLIENT_SECRET=$(curl -s \
  "$BASE/admin/realms/$REALM/clients/$KC_CLIENT_UUID/client-secret" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
| jq -r .value)

echo "$CLIENT_SECRET"

curl -s \
  -d "client_id=$CLIENT_ID" \
  -d "client_secret=$CLIENT_SECRET" \
  -d "username=$USERNAME" \
  -d "password=$PASSWORD" \
  -d "grant_type=password" \
  "$BASE/realms/$REALM/protocol/openid-connect/token" | jq



  MIIElzCCAn8CBgGec9fIXTANBgkqhkiG9w0BAQsFADAPMQ0wCwYDVQQDDAQxNzE3MB4XDTI2MDUyOTEzMDQ0MVoXDTI5MDUyOTEzMDYyMFowDzENMAsGA1UEAwwEMTcxNzCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAOQwIkG0bYo2A1Bzejxqxo3x5inYck9QAVrfDRKgrEKQab17buXJKxpSI2XZcCe3PWWfJsxUKsRvO0zLWwjoa4QOy+vwF+/8CZRoiAuBG/rcvtz3zb9+TCRzjykVkDrQkkss+GOcFa6EKuaKf9COEsrG6Fe2sfIdh0HvpPqAtCZwW8yIHup2QfKYmaFUDqN3o0hh16fMbDlgUCGJuqmO+SqmKt9a9nnbsylQlU0uh7Gja2/sTdQibp1AZI+kSvl9vRn8guWNKknD3qWd3xXl8QNagPSFuyt9AdYBuTiZb8ygctmNvIe29LBSD1Z4FywwV4cmPRlWpKOnv47qATCZG3dOEPFV3wKThLyL54tMi43SwmyQhW7atoPeoSf8HeCE6HUGxUDlhRYRS9xsssbUe37sQljauljNN/jg4YFmGeldHXWbSyDa1vBi9gKESpmGsVwHOA0zlxPHbIcUZBNR77POQr2kzNmqlb63xSWyHQoC/+VKQsOm0Z9A8HH/P4i8qsf/ipArWiwPC9BsLW+x8kPyGlcaJZTUG2CtFvYVZkHaENc3b6ky8J1PpO/LBKUjXfkqrlEAHr1NH5SHPc3OJYNO7bxzIf5Bvjxc4qZBS95LWY28wOlqnqOyrZhb96rPbzFmHRh/uNNpV4wHFPNiRH5jMzI8xuGxcPtNez2rMKcHAgMBAAEwDQYJKoZIhvcNAQELBQADggIBAJw4x8/djODRRqZ5Tg+aKFoZ1Pu472SjWD3sfyaSpzD+BOClj9cM5dSF+o8B+K+jhdzbb9E3G5t0XqroQbvjYINrGenAAgorjIgtuEcHgcM3Ag+S+Fr7+FusJVOr1XZ7okVcyCV0PPzmfh1oRAS5JiNGsymSGH+5/RkSrUPFjwSZMJ2S2nTFMhIrM1igIgSPcXI51aJNc/OY+i7+887+idatDm7i1+WTQSe3Ri2jP5AS2+uFx3XOba6XfYAu2x4AsGFCY7txyHf1yuQd+iNT8I78vaWRf/ad/6DDEUygtkrFtwu+fxVzv4J0+W0FCY1QiBA6AUkXTL5FZZ1uBmhrdWpFy8T7jSgLG0gOkLDm50Kur9YyJSxPrCixEZQ4YcjjsB2msIF8NsR8F2XXbIlczRZICQIHeD8so40FhZJmZZ1LWlY7bEiZz84Dwgr/o+Hw2FCO6eXurXjeVcceTidEv6IgjfMizkCPvuW4ACQFQd6ZaV1lbRar6+uXs56agY3xxEMiRuvGeyVsazNxOndenGxvg9u8hR6SCourMxrA5BP3aOpocgs8oqRawTz2iBU8SjblKJa0p5TMBP75nzttobGGKYA4FNtXFe0IQu0/cNqo3h3h2Prha7MnhIBwNmxh0Dp2hWuzLw2zXHHQqqsZKJAzGIazBHjJZn1CPEFMMYG2


CLIENTID="1717"
CLIENTSECRET="8Fg88HjzBSKn3S3Guz6SEcK7MDk0D1bD"


curl -X POST \
  http://localhost:8855/realms/master/protocol/openid-connect/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials" \
  -d "client_id=$CLIENTID" \
  -d "client_secret=$CLIENTSECRET" \
  -d "scope=openid"



TOKEN=$(curl -s \
  -d "client_id=admin-cli" \
  -d "username=admin" \
  -d "password=admin" \
  -d "grant_type=password" \
  http://localhost:8855/realms/master/protocol/openid-connect/token \
| jq -r .access_token)


curl -s \
  -H "Authorization: Bearer $TOKEN" \
  http://localhost:8855/admin/realms/master \
| jq '.accessTokenLifespan'


curl -s -X PUT \
  http://localhost:8855/admin/realms/master \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "accessTokenLifespan": 300
  }'


curl -s \
  -H "Authorization: Bearer $TOKEN" \
  http://localhost:8855/admin/realms/master/users | jq .





curl -s \
  -d "client_id=admin-cli" \
  -d "username=admin" \
  -d "password=admin" \
  -d "grant_type=password" \
  http://localhost:8855/realms/master/protocol/openid-connect/token


curl -s \
  -d "client_id=admin-cli" \
  -d "username=user1" \
  -d "password=123" \
  -d "grant_type=password" \
  http://localhost:8855/realms/master/protocol/openid-connect/token



### Start

```bash

docker ps -a -q | xargs docker rm -f

rm dockerdata -rf



mkdir -p dockerdata/keycloak/data/import


cat <<EOF> dockerdata/keycloak/data/import/demo-realm.json 
{
  "realm": "demo",
  "enabled": true,
  "clients" : [
  {
      "clientId" : "demo-client",
      "name" : "Demo Client",
      "enabled" : true,
      "protocol": "openid-connect",
      "publicClient": false,
      "secret": "demo-secret",
      "standardFlowEnabled": true,
      "directAccessGrantsEnabled": true,
      "serviceAccountsEnabled": true,
      "redirectUris": [
        "http://localhost:8855/*"
      ],
      "webOrigins": [
        "*"
      ]
  }
  ],
  "users" : [
   {
      "username" : "alice",
      "enabled" : true,
      "emailVerified" : true,
      "credentials" : [
       {
          "type" : "password",
          "value" : "123",
          "temporary" : false
       }
      ]
   },
 {
      "username" : "bob",
      "enabled" : true,
      "emailVerified" : true,
      "credentials" : [
       {
          "type" : "password",
          "value" : "123",
          "temporary" : false
       }
      ]
   }

  ]
}
EOF


docker run \
  -d --name keycloak \
  -p 8855:8080 \
  -e KC_BOOTSTRAP_ADMIN_USERNAME=admin \
  -e KC_BOOTSTRAP_ADMIN_PASSWORD=admin \
  -v $(pwd)/dockerdata/keycloak/data/import:/opt/keycloak/data/import:ro \
  quay.io/keycloak/keycloak:latest \
  start-dev --import-realm

docker logs keycloak -f


ADMIN_TOKEN=$(curl -s \
  -d "client_id=admin-cli" \
  -d "username=admin" \
  -d "password=admin" \
  -d "grant_type=password" \
  http://localhost:8855/realms/master/protocol/openid-connect/token \
| jq -r .access_token)




### Set token exp to 5 min

curl -s -X PUT \
  http://localhost:8855/admin/realms/demo \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "accessTokenLifespan": 300
  }'

#### Verify

curl -s \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  http://localhost:8855/admin/realms/demo \
| jq '.accessTokenLifespan'


### Get Admin token

ADMIN_TOKEN=$(curl -s \
  -d "client_id=admin-cli" \
  -d "username=admin" \
  -d "password=admin" \
  -d "grant_type=password" \
  http://localhost:8855/realms/master/protocol/openid-connect/token \
| jq -r .access_token)


### Get users

curl -s \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  "http://localhost:8855/admin/realms/demo/users" | jq '.[].username'


### Get clients

curl -s \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  "http://localhost:8855/admin/realms/demo/clients" | jq '.[].clientId'


```