### Install Powershell Core

```powershell

winget install Microsoft.PowerShell


```

### Check that Docker is running
> You may need to run the *Docker Desktop* program first

```powershell

docker images

```

### Intall Docker

```powershell

### If Virtulization is not enabled

Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart

wsl --install

winget install Docker.DockerDesktop

### Restart may be required to add your user to the Docker group


```

### Try Docker

```powershell

$image = "mcr.microsoft.com/azuredocs/aks-helloworld:v1";

docker pull $image;

### run a container of the image as standard on port 5555, inside powershell not detached

docker run -it --name app1 -p 5555:80 $image

curl localhost:5555

browse localhost:5555

### run as detached

docker run -it -d --name app1 -p 5555:80 $image

### List running containers

docker ps -a

### remove running/stopped container

docker rm app1 -f

### Run two images with separate env var

docker run -it -d -e TITLE=app1 --name app1 -p 5555:80 $image
docker run -it -d -e TITLE=app2 --name app2 -p 5556:80 $image

```

### Execute into container

```powershell

docker exec -it **** bash

docker exec -it ******** sh -c "echo 'test' >> test.txt"

docker exec -it ******** sh -c ls

```

### Start Nginx container and munlipulate it

```powershell

docker pull nginx

docker run -it -d --name nginx -p 5560:80 nginx

### List the existing web-folder
docker exec -it nginx sh -c "ls /usr/share/nginx/html"

### Cat the index.html file

docker exec -it nginx sh -c "cat /usr/share/nginx/html/index.html"

### Manipulate the index.html file

docker exec -it nginx sh -c "echo '<h1>Hello students</h1>' > /usr/share/nginx/html/index.html"

### This is not stateful

docker rm nginx -f
docker run -it -d --name nginx -p 5560:80 nginx
docker exec -it nginx sh -c "cat /usr/share/nginx/html/index.html"


```

### Use a folder as volume

```powershell

mkdir c:\temp\nginxweb

echo "<h1>Hello stateful students</h1>" > C:\temp\nginxweb\index.html

docker run -it -d --name nginx -v C:\temp\nginxweb:/usr/share/nginx/html -p 5561:80 nginx

curl localhost:5561

#### Now "kill" the container and create it again
docker rm nginx -f
docker run -it -d --name nginx -v C:\temp\nginxweb:/usr/share/nginx/html -p 5561:80 nginx
curl localhost:5561


#### Cleanup

get-item c:\temp\nginxweb | remove-item -force -recurse



```

### Delete all Docker Containers (running and stopped!)

```powershell

docker ps -a --format json | ConvertFrom-Json | ForEach-Object {docker rm $_.ID -f}

```

### Install Kind

```powershell

winget install Kubernetes.kubectl

winget install Kubernetes.kind

```



