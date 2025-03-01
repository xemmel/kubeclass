```bash
sudo iptables -P FORWARD ACCEPT

rm cp_temp.yaml
cat preflight.yaml > cp_temp.yaml
cat cp.yaml >> cp_temp.yaml


multipass launch --name cp-1 --cloud-init cp_temp.yaml --disk 20G --memory 2G --cpus 2

```