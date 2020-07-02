#!/bin/bash

# Step 7 : Create PV and PVC
echo "Step 7 : Create PV and PVC"

kubectl create -f /vagrant/docs/pv-jenkins-pv1.yaml --namespace jenkins
kubectl get pv -n jenkins  -o wide

kubectl create -f /vagrant/docs/pvc-jenkins-pv1.yaml --namespace jenkins
kubectl get pvc -n jenkins -o wide

# Step 8: install jenkins chart 
echo "Step 8: install jenkins chart"

helm install stable/jenkins --name jenkins --values /vagrant/docs/v2/jenkins.values --namespace jenkins
kubectl get all	-n jenkins



