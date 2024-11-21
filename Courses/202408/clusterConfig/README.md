kind create cluster --name multinodes --config .\multicluster.yaml

kind create cluster --name volumes --config .\volumecluster.yaml


kind create cluster --name ingress --config .\ingresscluster.yaml



