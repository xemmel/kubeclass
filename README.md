## Kubernetes class
## Morten la Cour

## Getting started

### install Chocolatey

In Powershell (Administrator
)
```powershell


Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

```

### install Powershell 7 (optional)

```powershell
choco install powershell-core -y
```

### install software (Beginner)

```powershell

choco install azure-cli -y
choco install kubernetes-cli -y
choco install vscode -y
```

### install software (Advanced)

```powershell
choco install kubernetes-helm -y
```