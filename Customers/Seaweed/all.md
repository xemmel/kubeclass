rm -fr statgpt-wrapper
mkdir statgpt-wrapper

cat<<EOF>> statgpt-wrapper/Chart.yaml
apiVersion: v2
name: statgpt-wrapper
description: Full statgpt Chart
type: application
version: 0.1.0

dependencies:
  - name: seaweedfs
    repository: https://seaweedfs.github.io/seaweedfs/helm
    version: "4.45.0"

  - name: valkey
    version: "0.11.0"
    repository: https://valkey.io/valkey-helm/
EOF

mkdir -p statgpt-wrapper/templates


cat<<EOF>> statgpt-wrapper/templates/seaweed-secrets.yaml
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
          "name": "admin",
          "credentials": [{
            "accessKey": "admin",
            "secretKey": "{{ .Values.seaweed.admin.password }}"
          }],
          "actions": ["Admin", "Read", "Write"]
        },
        {
          "name": "writer",
          "credentials": [{
            "accessKey": "writer",
            "secretKey": "{{ .Values.seaweed.writer.password }}"
          }],
          "actions": ["Read", "Write"]
        },
        {
          "name": "reader",
          "credentials": [{
            "accessKey": "reader",
            "secretKey": "{{ .Values.seaweed.reader.password }}"
          }],
          "actions": ["Read"]
        }
      ]
    }
EOF

cat<<EOF>> statgpt-wrapper/templates/secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: password-secrets
stringData:
  seaweed_reader_password: "{{ .Values.seaweed.reader.password }}"
  seaweed_reader_user: "reader"
  seaweed_writer_password: "{{ .Values.seaweed.writer.password }}"
  seaweed_reader_user: "writer"
  seaweed_writer_password: "{{ .Values.seaweed.writer.password }}"
  seaweed_admin_user: "admin"
  seaweed_admin_password: "{{ .Values.seaweed.admin.password }}"

  valkey_default_password: "{{ .Values.valkey.default.password }}"
  valkey_reader_password: "{{ .Values.valkey.reader.password }}"
  valkey_writer_password: "{{ .Values.valkey.writer.password }}"

EOF

cat<<EOF>> statgpt-wrapper/values.yaml

storageClass: &storageClass local-path

valkey:
  auth:
    enabled: true
    usersExistingSecret: password-secrets
    aclUsers:
      default:
        passwordKey: valkey_default_password
        permissions: "~* &* +@all"
      reader:
        passwordKey: valkey_reader_password
        permissions: "~* &* -@all +@read +ping"
      wrtier:
        passwordKey: valkey_writer_password
        permissions: "~* &* +@all -@admin -@dangerous"

  replica:
    enabled: true
    replicas: 3
    persistence:
      size: 10Gi
      storageClass: *storageClass
      accessModes:
        - ReadWriteOnce

seaweedfs:
  master:
    replicas: 1

    data:
      type: persistentVolumeClaim
      size: 1Gi
      storageClass: *storageClass
  filer:
    replicas: 1
    data:
      type: persistentVolumeClaim
      size: 10Gi
      storageClass: *storageClass
  
  s3:
    enabled: true
    enableAuth: true
    existingConfigSecret: seaweedfs-s3-users
    replicas: 1
  volume:
    dataDirs:
      - name: data1
        type: persistentVolumeClaim
        size: 10Gi
        storageClass: *storageClass
EOF

