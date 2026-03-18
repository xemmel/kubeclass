
```powershell

kubectl auth can-i list namespaces --all-namespaces --as=system:serviceaccount:auth:tekno-account

```

### Get Cert

```bash

kubectl config view --raw -o jsonpath='{.users[0].user.client-certificate-data}' \
| base64 -d \
| openssl x509 -noout -subject -nameopt multiline

```