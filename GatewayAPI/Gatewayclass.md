

```yaml

apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: whatever
spec:
  controllerName: gateway.envoyproxy.io/gatewayclass-controller
  description: bla
  parametersRef: 
       ......
       
