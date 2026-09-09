helm dependency build ./statgpt-wrapper

helm install statgpt ./statgpt-wrapper \
  --namespace statgpt \
  --create-namespace \
  --set "seaweed.reader.password=1234" \
  --set "seaweed.writer.password=12345" \
  --set "seaweed.admin.password=123456" \
  --set "valkey.default.password=2234" \
  --set "valkey.reader.password=22345" \
  --set "valkey.writer.password=223456"





kubectl get secret --namespace statgpt password-secrets -o yaml


kubectl get secret --namespace statgpt password-secrets -o json | jq '.data | to_entries[0].value' -r | base64 -d


helm uninstall statgpt --namespace statgpt

kubectl delete namespace statgpt


kubectl get all --namespace statgpt

kubectl get pv,pvc -A



### Check seaweed users

kubectl get secret -n statgpt seaweedfs-s3-users -o json \
  | jq -r '.data | to_entries[0].value' \
  | base64 -d \
  | jq -r '.identities[].name'


