## Docker Namespaces


### Compare root namespaces and container namespaces

```bash

CONTAINER_NAME="webserver1"
CONTAINER_PID=$(docker inspect $CONTAINER_NAME | jq '.[] | .State.Pid')

ls /proc/$$/ns -l
sudo ls /proc/$CONTAINER_PID/ns -l




```

### Exec into container 
```bash

CONTAINER_NAME="webserver1"

### With docker

docker exec -it $CONTAINER_NAME bash

### with pure namespacing

sudo nsenter --target $(docker inspect $CONTAINER_NAME | jq '.[] | .State.Pid') --all


### nginx test
ls /usr/share/nginx/html/ -l

```


### Start Process Inside container


```bash

docker run -d --name demo alpine sleep 1000

docker exec -it demo sh


sleep 600 &


### Outside

ps aux | grep sleep

sudo pkill -f "sleep 600"


```