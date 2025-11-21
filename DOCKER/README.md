
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

#### Install sqlcmd

```bash

sudo su

curl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc
curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list | tee /etc/apt/sources.list.d/mssql-release.list
exit

sudo apt-get update
sudo apt-get install mssql-tools18 unixodbc-dev


echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bash_profile
source ~/.bash_profile


```

#### Execute

```bash

sqlcmd -S localhost -C -U sa -P 'YourNewP@ssw0rd123!' -Q "select name from sys.databases;"


```