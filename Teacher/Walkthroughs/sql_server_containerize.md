## SQL SERVER Container

```bash

### SQL No mount

docker network create datanet

PASSWORD="YourNewP@ssw0rd123!"
CURRENTDIR=$(pwd)

docker run -e "ACCEPT_EULA=Y" \
	-e "SA_PASSWORD=$PASSWORD" \
    -p 1434:1433 \
	--name sqlserver1 \
	--network datanet \
	-d mcr.microsoft.com/mssql/server:2022-latest


### MOUNT

sudo mkdir -p dockerdata/sql/{data,log,secrets}
sudo chown -R 10001:0 dockerdata/sql
sudo chmod -R 770 dockerdata/sql

docker run -e "ACCEPT_EULA=Y" \
	-e "SA_PASSWORD=$PASSWORD" \
    -p 1433:1433 \
	--name sqlserver \
	--network datanet \
	-v $CURRENTDIR/dockerdata/sql/data:/var/opt/mssql/data  \
	-v $CURRENTDIR/dockerdata/sql/log:/var/opt/mssql/log \
    -v $CURRENTDIR/dockerdata/sql/log/secrets:/var/opt/mssql/secrets \
	-d mcr.microsoft.com/mssql/server:2025-latest


### Install sqlcmd

sudo su

curl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc
curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list | tee /etc/apt/sources.list.d/mssql-release.list
exit

sudo apt-get update
sudo apt-get install mssql-tools18 unixodbc-dev


echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bash_profile
source ~/.bash_profile


### Execute

sqlcmd -S localhost,1434 -C -U sa -P $PASSWORD -Q "select name from sys.databases;"

sqlcmd -S localhost -C -U sa -P $PASSWORD -Q "select name from sys.databases;"


sqlcmd -S localhost -C -U sa -P $PASSWORD -Q "create database test;"
sqlcmd -S localhost -C -U sa -P $PASSWORD -d test -Q "create table dbo.Products(id int identity(1,1) primary key, ProductName nvarchar(max) );"
sqlcmd -S localhost -C -U sa -P $PASSWORD -d test -Q "select * from dbo.Products;"



```