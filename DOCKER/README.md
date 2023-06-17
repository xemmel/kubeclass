### Create simple container image

```powershell

docker run -p 5555:80 mcr.microsoft.com/azuredocs/aks-helloworld:v1

```

Can be run http://localhost:5555


### Kill the image

```powershell

### List all running containers

docker ps 

### Stop the container

docker stop 123456

### List all containers (also stopped)

docker ps -a

### Remove the stopped container

docker rm 123456

```

## Clean up containers

```powershell

$mask = Read-Host("mask");
docker ps -a --format='{{json .}}' | ConvertFrom-Json | Where-Object {$_.Image -like "*$($mask)*"} | ForEach-Object {docker rm $_.ID -f};

```