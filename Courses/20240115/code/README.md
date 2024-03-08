### Docker build 

In folder where *Dockerfile* resides

```powershell

docker build -t sleeper:0.1 .


docker run -it -d -e x_delay=20000 sleeper:0.1


docker logs 48b8ead3cdd20 -f


```

### Load image into kind

```powershell

kind load docker-image sleeper:0.1 --name multicluster

```