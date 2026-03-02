## Setup

### Install Powershell Core

- Open **Windows Powershell**

- Run

```powershell

winget install Microsoft.PowerShell

```
- Close **Windows Powershell**

- Open **Terminal**

  - Arrow Down / Settings
  - Under *Default Profile* Select *PowerShell* NOT *Windows PowerShell*
  - Click *Save*

- Restart **Terminal**

[Back to top](#setup)

### Install WSL (Windows Subsystem for Linux)

- In *Powershell*

```powershell

wsl --install
wsl --update

wsl --install Ubuntu-24.04

```

- Restart the *Terminal* again
- Expand the *Arrow Down* and verify that you now have **Ubuntu-24.04**
- Open an instance of *Ubuntu*

[Back to top](#setup)


### Install docker desktop

- In *Ubuntu*

```bash

sudo apt update
sudo apt upgrade -y

sudo apt install docker.io -y
sudo usermod -aG docker $USER
newgrp docker


```

[Back to top](#setup)

### Install kubectl

```bash

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

[Back to top](#setup)


### Install Kind

```bash

curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.31.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind


```

[Back to top](#setup)



