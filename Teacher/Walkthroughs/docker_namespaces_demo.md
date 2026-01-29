## Raw Docker 


```bash
## docker deep dive


multipass delete --all --purge

multipass launch --memory 2G --disk 20G --cpus 2 --name testserver


multipass shell testserver

sudo apt update && sudo apt upgrade -y


## Docker

sudo apt install docker.io -y
sudo usermod -aG docker $USER
newgrp docker




docker run --name webserver1 --publish 7777:80 --detach nginx
docker exec webserver1 sh -c 'echo "<html><body><h1>Hello</h1></body></html>" > /usr/share/nginx/html/index.html'
docker exec webserver1 sh -c 'cat /usr/share/nginx/html/index.html'

curl localhost:7777





docker inspect webserver1 | grep Pid

CONTAINERPID=$(docker inspect webserver1 | jq .[].State.Pid)

sudo ls /proc/$CONTAINERPID/ns -l
sudo ls /proc/$$/ns -l

sudo nsenter --target $CONTAINERPID --cgroup --ipc --mount --net --pid --uts bash

cat /usr/share/nginx/html/index.html


docker exec -it webserver1 bash


diff

- cgroup
- ipc
- mnt
- net
- pid
- pid_for_children (same as pid)
- uts

same

- time
- time_for_children (same as time)
- user


```