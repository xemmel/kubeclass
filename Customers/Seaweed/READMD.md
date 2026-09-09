## seaweed


```bash

helm repo add seaweedfs https://seaweedfs.github.io/seaweedfs/helm
helm search repo seaweedfs

helm show values seaweedfs/seaweedfs > seaweed_all_values.yaml


rm -f seaweed_user_secret.yaml
cat<<EOF>> seaweed_user_secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: seaweedfs-s3-users
type: Opaque
stringData:
  seaweedfs_s3_config: |
    {
      "identities": [
        {
          "name": "poweruser",
          "credentials": [
            {
              "accessKey": "poweruser",
              "secretKey": "12345678"
            }
          ],
          "actions": [
            "Read",
            "Write",
            "List",
            "Tagging",
            "ReadAcp",
            "WriteAcp"
          ]
        },
        {
          "name" : "reader",
          "credentials" : [
             {
              "accessKey": "reader",
              "secretKey": "123456789"
             }
          ],
          "actions" : [
              "Read"
           ]
        }
      ]
    }
EOF

rm -f seaweed_values.yaml
cat<<EOF>> seaweed_values.yaml
s3:
  enabled: true
  enableAuth: true
  existingConfigSecret: seaweedfs-s3-users
  credentials:
    admin:
      accessKey: admin
      secretKey: { .Values.password | quote }
volume:
  dataDirs:
    - name: data1
      type: persistentVolumeClaim
      size: 10Gi
      storageClass: local-path
      maxVolumes: 100
EOF

kubectl create namespace seaweed

kubectl apply --filename seaweed_user_secret.yaml --namespace seaweed


filer:
  s3:
    enabled: true
    enableAuth: true
    existingConfigSecret: seaweedfs-s3-users



helm install seaweedfs seaweedfs/seaweedfs \
  --namespace seaweed \
  --values seaweed_values.yaml


helm uninstall seaweedfs \
  --namespace seaweed


"actions": [
  "Read:mybucket",
  "Write:mybucket",
  "List:mybucket",
  "Tagging:mybucket",
  "ReadAcp:mybucket",
  "WriteAcp:mybucket"
]





## Valkey


aclUsers:
  reader:
    enabled: true
    password: "ReaderSecret123!"
    rules: "~* +@read"

  writer:
    enabled: true
    password: "WriterSecret123!"
    rules: "~* +@read +@write"



~*       # all keys
+@read   # all commands classified as read
+@write  # all commands classified as write



~*   → all keys
&*   → all Pub/Sub channels



```


#### Helm values in secret

```

{{ .Values.seaweed.users.app1.accessKey | quote }}

```