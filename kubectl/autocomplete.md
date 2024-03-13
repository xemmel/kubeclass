```powershell

# Create profile script
New-Item $PROFILE -Force
# Output kubectl Powershell completion to profile script
kubectl completion powershell >> $PROFILE
# Dot-source current profile script
. $PROFILE


```