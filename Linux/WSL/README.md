## WSL

### install

```powershell

## Check virtualization

Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform

## If virtualization is not enabled

Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart

wsl --update

wsl.exe --list --online

wsl --install [disto]

```