#!/bin/bash

# Set the script name
script_name="container_d_setup.sh"

# Download the script
curl -O https://raw.githubusercontent.com/xemmel/kubeclass/master/CustomServers/Scripts/$script_name

# Make sure we can execute the script
chmod +x $script_name

# Run the downloaded script
./$script_name