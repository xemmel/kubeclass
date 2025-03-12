```bash
cat <<EOF | tee finalize_test.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mymap
  finalizers:
  - kubernetes
EOF

```

### Execute

```bash

kubectl create namespace finalize-test
kubectl config set-context --current --namespace finalize-test
kubectl apply --filename finalize_test.yaml

kubectl get configmaps

kubectl get configmaps mymap -o yaml | grep finalizers -A 2
kubectl get configmap mymap -o yaml | grep dele

kubectl delete configmap mymap &

kubectl patch configmap mymap --type json --patch='[ { "op": "remove", "path": "/metadata/finalizers" } ]'


kubectl delete namespace finalize-test
rm finalize_test.yaml;


```
