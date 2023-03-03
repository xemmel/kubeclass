## Inject ConfigMap in Deployment

```yaml
        env:
        - name: TITLE
          valueFrom:
            configMapKeyRef:
              name: my3demo-config
              key: thetitle
              
```