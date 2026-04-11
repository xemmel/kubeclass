## APT

```bash
http://archive.ubuntu.com/ubuntu
http://security.ubuntu.com/ubuntu


curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg

curl -fsSL https://packages.microsoft.com/config/ubuntu/24.04/mssql-server-2025.list | sudo tee /etc/apt/sources.list.d/mssql-server-2025.list



ls /etc/apt/sources.list.d/ -l
ls /etc/apt/keyrings/ -l

ls /usr/share/keyrings/ -l

ls /var/lib/apt/lists/ -l

cat /etc/apt/sources.list.d/ubuntu.sources | grep -v "#"

```