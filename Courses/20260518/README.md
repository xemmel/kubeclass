# 2026-05-18

## Installation

### In powershell

```powershell

winget install Microsoft.WindowsTerminal

winget install Canonical.Multipass

winget install Microsoft.VisualStudioCode

```

### Launch kindserver

```powershell

multipass launch --name kindserver --memory 4GB --cpus 2 --disk 20GB devel

multipass shell kindserver

```

### Install docker 

```bash

sudo apt install docker-buildx -y
sudo usermod -aG docker $USER
newgrp docker


docker images

```


### install kubectl

```bash
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

### install kind

```bash

curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.31.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind


```