# Linux

## No sudo password prompt

```bash

sudo visudo

## change
%sudo   ALL=(ALL:ALL) ALL

## to

%sudo   ALL=(ALL:ALL) NOPASSWD:ALL

## If you are not member of the group sudo then make a new entry where you replace %sudo with your username or a group

```

## Update

```bash
sudo apt update && sudo apt upgrade -y
```


[Back to top](#linux)

## Install



[Back to top](#linux)
## Python

### Install

```bash
sudo apt install python3 python3-pip python3-venv -y
```

### Create dev env

```bash
python3 -m venv devenv
source devenv/bin/activate
```

[Back to top](#linux)

### Create small API

```bash

```


[Back to top](#linux)