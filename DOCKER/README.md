## Clean up containers

```powershell

$mask = Read-Host("mask");
docker ps -a --format='{{json .}}' | ConvertFrom-Json | Where-Object {$_.Image -like "*$($mask)*"} | ForEach-Object {docker rm $_.ID -f};

```