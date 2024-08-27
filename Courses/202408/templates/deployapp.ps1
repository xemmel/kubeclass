$appName = "app1";
## $appName = "app2";


kubectl create namespace $appName;

kubectl apply --filename ".\templates\$($appName)deployment.yaml" --namespace $appName;


