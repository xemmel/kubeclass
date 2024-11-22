- Create the hello world deployment

- Deploy an ingress controller

```powershell

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

```
- Create a ingress.yaml file

```yaml

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
    - http:
        paths:
          - path: /hello1
            pathType: Exact
            backend:
              service:
                name: hellotest-service  ## Might be different
                port:
                  number: 80

```

- deploy the ingress

- localhost/hello1