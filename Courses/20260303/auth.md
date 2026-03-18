

```bash

kubectl config view --raw -o jsonpath='{.users[0].user.client-certificate-data}' | base64 -d | openssl x509 -noout -subject








kubectl auth can-i list namespaces --all-namespaces --as=system:serviceaccount:auth:tekno-account

cat << EOF >> serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tekno-account
EOF

cat << EOF >> role_list_namespaces.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: namespace-lister
rules:
- apiGroups: [""]
  resources: ["namespaces"]
  verbs: ["list"]
EOF

cat << EOF >> rolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: list-namespaces-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: namespace-lister
subjects:
- kind: ServiceAccount
  name: tekno-account
  namespace: auth
EOF

```