### First task

- Create namespace volumedemo
- Set kubectl to namespace
- create deployment and service image: nginx:latest

use port-forward and check webpage in browser



## Manual upload

```powershell   

docker pull nginx

kind load docker-image nginx:latest --name volumecluster


```