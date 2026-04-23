### Simple CRD



```bash

kubectl create namespace crdsample

kubectl apply --namespace crdsample --filename - <<EOF
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: crdtests.example.com
spec:
  group: example.com
  scope: Namespaced
  names:
    plural: crdtests
    singular: crdtest
    kind: CrdTests
    shortNames:
      - ctest
  versions:
    - name: 
EOF

```