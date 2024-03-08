### Install

### If Docker access problems 

```powershell

whoami

net localgroup docker-users "yourusername" /ADD

restart-computer

```

```powershell

choco install kind -y

```

ALT:

```powershell

### List all "path" folders

($Env:Path).Split(';') | ForEach-Object { if (Test-Path $_) { $_ } }


```

```powershell

curl.exe -Lo kind-windows-amd64.exe https://kind.sigs.k8s.io/dl/v0.20.0/kind-windows-amd64

Move-Item .\kind-windows-amd64.exe c:\some-dir-in-your-PATH\kind.exe

```
#### Restart computer


### Update

Browse

https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi

> Install it

```powershell

wsl --set-default-version 2

```


```powershell

kind create cluster


```