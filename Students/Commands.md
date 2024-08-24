## Windows first then linux

### Namespace

```powershell

$namespace = "firsttest";

NAMESPACE="firsttest"

kubectl create namespace $namespace;

kubectl create namespace $NAMESPACE



### switch context to namespace

kubectl config set-context --current --namespace $namespace;

kubectl config set-context --current --namespace $NAMESPACE


```

## List resources inside current namespace 

```powershell

### Lists most common resources NOT ALL

kubectl get all

### Add Configmap to the resources

kubectl get all,configmaps

```

