### Raw service

```yaml

apiVersion: v1
kind: Service
metadata:
  name: test-service
spec:
  selector:
    app: test
  ports:
    - port: 80
      targetPort: 80

```

