### Config maps


#### Key Ref

```bash

kubectl apply --filename configmap.yaml
kubectl apply --filename deployment.yaml


```

- Change your config map and re-apply

- Changes do not apply until you do a 

```bash

kubectl rollout restart deployment webserverhello-deployment

```

#### Cleanup

```bash
kubectl delete --filename configmap.yaml
kubectl delete --filename deployment.yaml

```

#### Whole config map mapped as Env

```bash
kubectl apply --filename configmap_container.yaml
kubectl apply --filename deployment_container_configmap.yaml

```

#### View the env vars in the container

> Pod name differs!

```bash

kubectl exec -it webserverhello-deployment-7d98c6768d-576xr -- env

```