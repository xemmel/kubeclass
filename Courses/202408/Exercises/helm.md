### Deploy helm

kubeclass\Courses\202408\clusterConfig>


kind get clusters

kind delete cluster --name ???

iisreset /stop


kind create cluster --name ingress --config .\ingresscluster.yaml


## Ingress controller

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

curl localhost     -> nginx 404

:-)

\kubeclass\Courses\202408>


helm install app1 .\HelmClusterApp\ --set "app.name=app1" --set "replicas=7" --namespace app1 --create-namespace

helm install app2 .\HelmClusterApp\ --set "app.name=app2" --set "replicas=3" --namespace app2 --create-namespace


curl localhost/app1
curl localhost/app2
