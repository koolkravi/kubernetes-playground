#!/bin/bash

git clone https://github.com/nginxinc/kubernetes-ingress.git
cd kubernetes-ingress/
cd deployments/

### Configure RBAC
kubectl apply -f common/ns-and-sa.yaml
kubectl apply -f rbac/rbac.yaml

### Create Common Resources
kubectl apply -f common/default-server-secret.yaml
kubectl apply -f common/nginx-config.yaml

### Run the Ingress Controller - Use a DaemonSet
kubectl apply -f daemon-set/nginx-ingress.yaml

## delete kubernetes-ingress
rm -R kubernetes-ingress