```bash

multipass launch --name con-1 --cpus 2 --memory 2G

multipass launch --name con-1 --disk 20G --memory 2G --cpus 2
multipass launch --name wor-1 --disk 20G --memory 2G --cpus 2


multipass shell con-1


multipass stop con-1

multipass restore con-1.con-1-s

multipass start


```