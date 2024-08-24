
## Table of content

- [Table of content](#table-of-content)
  - [Create pod](#create-pod)
  - [Apply pod template](#apply-pod-template)
  - [Restart pods](#restart-pods)
  - [Log and debug functions](#log-and-debug-functions)
  - [Port forward](#port-forward)
  - [ConfigMap](#configmap)
  - [Secrets](#secrets)
  - [Maintanence](#maintanence)
  - [Ingress](#ingress)
  - [HELM](#helm)



### Create pod

```powershell

### Create namespace
$namespace = "yournamespacename";

kubectl create namespace $namespace;


### switch context to namespace

kubectl config set-context --current --namespace $namespace;

### Create a pod

kubectl run pod1 --image mcr.microsoft.com/azuredocs/aks-helloworld:v1

### Describe a pod

kubectl describe pod pod1


### Remove a pod

kubectl delete pod pod1



```

[Back to top](#table-of-content)


### Apply pod template

```yaml

apiVersion: v1
kind: Pod
metadata:
  name: forcapod7
spec:
  containers:
  - image: nginx
    name: forcapod7



```

```powershell

### Apply template
kubectl apply -f .....

### Delete artifacts inside the template
kubectl delete -f .....


```

[Back to top](#table-of-content)

### Restart pods

```powershell

kubectl rollout restart deployment.apps/deploymentname

```

[Back to top](#table-of-content)


### Log and debug functions

```powershell

### log single pod (-f to live log)

kubectl logs podname (-f)  

### log several pods with label

kubectl logs -l bent=forcaapp1 -f

### Execute into pod

kubectl exec -it podname -- bash

### View pods with ip-addresses

kubectl get pods -o wide

### curl [pod-ip]

```



[Back to top](#table-of-content)

### Port forward

```powershell

kubectl port-forward service/deployment1-service 5555:80

```

[Back to top](#table-of-content)

### ConfigMap


```yaml

 - image: mcr.microsoft.com/azuredocs/aks-helloworld:v1
   name: andersand
   env:
     - name: TITLE
       value: 'Hardcoded Title'

```

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: myconfigmap
data:
  webtitle: 'Web app1111'

```

```yaml

 - image: mcr.microsoft.com/azuredocs/aks-helloworld:v1
        name: andersand
        env:
          - name: TITLE
            valueFrom:
              configMapKeyRef:
                name: myconfigmap
                key: webtitle

```


[Back to top](#table-of-content)


### Secrets

```powershell

kubectl create secret generic demo2-secret --from-literal=thepassword=verysecret

```

```yaml

apiVersion: v1
kind: Secret
metadata:
  name: demo01-secret
type: Opaque
data:
  thesecret: [base64stuff]

```

```yaml

          valueFrom:
            secretKeyRef:
              name: demo2-secret
              key: thepassword

```

[Back to top](#table-of-content)


### Maintanence

```powershell

kind delete cluster

.\Kind\Cluster\create_cluster.ps1

```

```yaml

## View nodes
kubectl get nodes

## Not Scheduled (Tainted)

kubectl cordon nodename


## Scheduled (Untainted)
kubectl uncordon nodename


## Drain

kubectl drain --ignore-daemonsets --force [node name]


```

### Ingress

```powershell

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml


```


### HELM

- Chart.yaml                
- values.yaml               
- templates/               
  - _helpers.tpl            
  - deployment.yaml         
  - service.yaml            
  - ingress.yaml
  - ....


```yaml 

helm install name .\...\HelmChart\ --namespace $namespace --create-namespace

### If in correct namespace

helm update name .\...\HelmChart\

```



