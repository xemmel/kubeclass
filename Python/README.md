## Python

### Raw walkthrough
```bash

sudo iptables -P FORWARD ACCEPT

multipass launch --name pytdev --disk 30G --memory 4G --cpus 2

multipass shell pytdev


sudo apt update && sudo apt upgrade -y

sudo apt install python3-pip python3-venv -y

mkdir code

cd code

python3 -m venv devenv

source ./devenv/bin/activate

pip install fastapi[standard]


mkdir api1

cd api1





[ -e app.py ] && rm app.py

cat<<EOF>> app.py
from fastapi import FastAPI

app = FastAPI()

@app.get("/version")
async def getversion():
  return { "version" : "1.0" }
  
@app.get("/items/{item_no}")
async def getitembyitemno(item_no: int):
  return { "item" : { "itemNo" : item_no } }
EOF


## fastapi dev

uvicorn app:app --port 8000 --no-access-log &

## Press enter

curl localhost:8000/items/123

fg


### Docker

sudo apt install docker.io -y
sudo usermod -aG docker $USER
newgrp docker


[ -e requirements.txt ] && rm requirements.txt
echo -e "fastapi[standard]>=0.113.0,<0.114.0\npydantic>=2.7.0,<3.0.0" >> requirements.txt


[ -e Dockerfile ] && rm Dockerfile
cat<<EOF>>Dockerfile
FROM python:3.14

WORKDIR /code

COPY ./requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . /code/app

CMD ["fastapi", "run", "app/app.py", "--port", "80"]
EOF

docker build --tag api1:1.0 .

docker run --name api1 --publish 8899:80 -d api1:1.0

curl localhost:8899/items/125


docker ps -f name=api1 -q | xargs docker rm -f



exit

exit


multipass delete pytdev --purge

```

