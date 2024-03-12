### CAN I

```powershell

kubectl auth can-i list namespaces --all-namespaces --as=system:serviceaccount:roles:list-namespaces-sa

```

### Get Token

```powershell

$rawToken = kubectl get secret list-namespaces-token -o jsonpath='{.data.token}';
$rawToken;

$decodedBytes = [System.Convert]::FromBase64String($rawToken)
$token = [System.Text.Encoding]::UTF8.GetString($decodedBytes)
$token;

curl https://127.0.0.1:57126/api/v1/namespaces -H "Authorization:Bearer $token" -k



```