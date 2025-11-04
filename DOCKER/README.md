
### Network

```bash

docker network create datanet

```

### SQL SERVER


#### FILES

```bash

mkdir dockerdata
sudo mkdir -p dockerdata/sql/{data,log,secrets}
sudo chown -R 10001:0 dockerdata/sql
sudo chmod -R 770 dockerdata/sql

```


#### Run Container

```bash


CURRENTDIR=$(pwd)
docker run -e "ACCEPT_EULA=Y" \
	-e "SA_PASSWORD=YourNewP@ssw0rd123!" \
    -p 1433:1433 \
	--name sqlserver1 \
	--network datanet \
	-v $CURRENTDIR/dockerdata/sql/data:/var/opt/mssql/data  \
	-v $CURRENTDIR/dockerdata/sql/log:/var/opt/mssql/log \
    -v $CURRENTDIR/dockerdata/sql/log/secrets:/var/opt/mssql/secrets \
	-d mcr.microsoft.com/mssql/server:2022-latest


```