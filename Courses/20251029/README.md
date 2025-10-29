### DEMO


#### Microservices

- Loosely coupled services
- fine-grained
- Develop/Deploy Services independently
- Improve modularity, scalability, and adaptability


- More Complexitity (Cannot test everything in a monolit)



- Used everywhere    (Azure Entra)
   - Azure and O365 do not go about building their own Identity Provider
   - Separation of concern (Do what you are good at)
   - 


[Back to top](#demo)



#### Docker / Containers

- There doesn't have to be a 1-1 between containers and microservices!
    - You can work with microservices without use of containers
	- You can use containers to "host" a monolit
	
- Mini VM
  - Fast deployment
  - Ships with all prereq/Dependencies
  - Easy rollback
  - Resource Control
  - Scalability/Security/Network control   (Probably needs an Orchestrator like Kubernetes)
  
 
- Docker Desktop (runs on Linux, can run in "Windows" (Not really) with WSL (Windows Subsystem for Linux)


#### Install windows

```powershell

wsl --install
wsl --update

winget install Docker.DockerDesktop


```


[Back to top](#demo)

#### Install linux

```bash

wsl --install
wsl --update

wsl --install Ubuntu-24.04

```

[Back to top](#demo)

open/close terminal  -> You should now be able to open a new tab with Ubuntu 

```bash

sudo apt update
sudo apt upgrade -y

sudo apt install docker.io -y

sudo usermod -aG docker $USER
newgrp docker

```

#### First container / "Mini" VM

```bash

docker run -p 5000:80 --name myfirstcontainer -d nginx

```


[Back to top](#demo)

#### List containers (both running and exited)

```bash

docker ps -a --format json | jq '{Name: .Names, State: .State, Net: .Networks,Ports: .Ports}'

```
[Back to top](#demo)


