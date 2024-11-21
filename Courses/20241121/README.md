### Creating your debug pod in a namespace

kubectl create namespace debug

kubectl run debug --image=nginx --namespace debug

## Use it

kubectl exec -it --namespace debug  debug -- bash