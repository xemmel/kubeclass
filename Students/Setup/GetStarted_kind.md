
## install powershell core

- open normal *powershell*

```powershell

winget install Microsoft.PowerShell

```

- Close normal *powershell* again
- Search *Windows key* for **powers**
- A new black icon **Powershell 7 (x64)** should appear
- Open it, right click on opened icon and *pin to taskbar*



## install wsl 

```powershell

Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart

wsl --install

```

## linux

```powershell

wsl.exe --list --online

wsl --install Ubuntu-22.04

### start

wsl

cd ~

sudo apt update
sudo apt upgrade -y

```




### Install multipass

```bash

sudo snap install multipass

```

### Create a single multipass server

```bash

multipass launch --name kindserver --disk 30G --memory 4G --cpus 2

```

### Launch multipass server

```bash

multipass shell kindserver

```


### install kind on multipass server

```bash

sudo apt update
sudo apt upgrade -y

### Install docker

sudo apt install docker.io -y

sudo usermod -aG docker $USER
newgrp docker


### Install kind

curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.29.0/kind-linux-amd64

chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind


### install kubectl 

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

chmod +x kubectl
mkdir -p ~/.local/bin
mv ./kubectl ~/.local/bin/kubectl

### kubectl completion

sudo apt-get install -y bash-completion
echo "source <(kubectl completion bash)" >> ~/.bashrc
source ~/.bashrc


```

## windows

### check environment

- Search for *docker* if *Docker Desktop* appears as an installed program open it and wait for it to run
  - There should be a green bar in the button left corner
- If *Docker* is installed and running you should be able to run the following command:

```powershell

docker images

```
### install docker desktop if needed

```powershell

winget install Docker.DockerDesktop

### Restart may be required to add your user to the Docker group

docker images

```

### Install kind and kubectl

```powershell

winget install Kubernetes.kubectl

winget install Kubernetes.kind

```


## Create simple cluster

```bash

kind create cluster

```


## Create config cluster

```bash

cat << EOF > cluster.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker
  - role: worker
EOF

kind create cluster --name multi --config cluster.yaml

rm cluster.yaml


kind delete cluster --name multi

```



## Cleanup

### linux

```bash

multipass delete --all --purge

```