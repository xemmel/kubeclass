docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=SuperUsers12345&&" `
   -p 1433:1433 --name sql1 --hostname sql1 `
   -d `
   mcr.microsoft.com/mssql/server:2022-latest


docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=SuperUsers12345&&" `
   -p 1434:1433 --name sql2 --hostname sql2 `
   -d `
   mcr.microsoft.com/mssql/server:2022-latest


docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=SuperUsers12345&&" `
   -p 4444:80 --name hello --hostname hello `
   -d `
   nginxdemos/hello


apiVersion: v1
kind: Pod
metadata:
  name: hello-pod
spec:
  containers:
    - name: hello-container
      image: nginxdemos/hello


kubectl apply --filename pod.yaml

kubectl get pods -o wide

github.com/xemmel/kubeclass

Students/Setup/debug_pod.md


kubectl exec -it debug --namespace debug -- curl ipaddress



.yaml

name: Morten
address:
  street: thestreet
  zipcode: 8000



addresses:
  - street: thestreet1
    zipcode: 8000
  - street: thestreet2
    zipcode: 8100
  - name: the 3rd address
    street: thestreet3



restart powershell 7

docker images


kind create cluster
kubectl get namespaces

--------------------------------

kubectl create namespace demo01
kubectl config set-context --current --namespace demo01





LB (Service)
- Static IP
- LB

pod2   (app:test)
pod3   (app:test)


Service


namespace: ns1
name: myservice
ipaddress: 1234

dns   myservice[.ns1]  -> 1234


kubernetes cluster

namespace test
namespace prod

---------------------------------------------------------

kubectl drain   -> Smid alle beboere ud!
kubectl cordon  -> Sæt en politiring rundt om noden


kubectl cordon nodename
kubectl drain nodename --ignore-daemonsets










