#!/bin/bash

# Set the script name
script_name="container_d_setup.sh"
script_name="kubeadm_setup.sh"

script_name="master_setup.sh"

script_name="worker_setup.sh"


# Download the script
curl -O https://raw.githubusercontent.com/xemmel/kubeclass/master/CustomServers/Scripts/$script_name

# Make sure we can execute the script
chmod +x $script_name

# Run the downloaded script
./$script_name


kubeadm token create --print-join-command



### Client
sudo ssh-keygen -f "/root/.ssh/known_hosts" -R "kube-master-01"

sudo scp kubeadmin@kube-master-01:~/.kube/config ~/.kube/config

