Clear-Host;

$namespace = "mongo";

kubectl create namespace $namespace;

kubectl config set-context --current --namespace $namespace;

kubectl apply -f .\Templates\mongo\Templates\configmap.yaml;
kubectl apply -f .\Templates\mongo\Templates\mongodb-deployment.yaml;
kubectl apply -f .\Templates\mongo\Templates\mongoexpress-deployment.yaml;


## kubectl delete namespace $namespace;

