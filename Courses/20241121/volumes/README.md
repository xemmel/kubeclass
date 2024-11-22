

- Create new cluster (delete the old first) with kind.yaml

- check the c:\temp\kind folder

- apply both pvc.yaml and elastic.yaml

kubectl get pv,pvc


debug pod:

### View indices
curl curl elastic-service.elastic:9200/_cat/indices

### Create new index

curl elastic-service.elastic:9200/index1 -X PUT

kubectl delete pod ......




