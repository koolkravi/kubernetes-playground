**Prometheus monitoring for Kubernetes Cluster and Grafana visualization**

# Prerequisite

## 1. Provision kubernetes custer 
[vagrant-provisioning-kubeadm](https://github.com/koolkravi/kubernetes-playground/tree/master/vagrant-provisioning-kubeadm)

```
vagrant up
```

## 2. Install Helm, tiller and Setup private docker registry

[See README Step 2 ](https://github.com/koolkravi/kubernetes-playground/tree/master/ci-cd-using-jenkins-helmchart-and-kubernetes)

### some commands 
```
kubectl -n kube-system get pods
helm list
```

## 3. Change permission of docker.sock and run docker command without sudo

[See README Step 3 ](https://github.com/koolkravi/kubernetes-playground/tree/master/ci-cd-using-jenkins-helmchart-and-kubernetes)

## 4 Create PV and PVC
```
kubectl create ns prometheus
kubectl create -f /vagrant/prometheus/pv-prometheus-pv1.yaml --namespace prometheus
kubectl create -f /vagrant/prometheus/pvc-prometheus-pv1.yaml --namespace prometheus

kubectl create -f /vagrant/prometheus/pv-prometheus-pv2.yaml --namespace prometheus
kubectl create -f /vagrant/prometheus/pvc-prometheus-pv2.yaml --namespace prometheus

kubectl get pv,pvc -n prometheus  -o wide
kubectl get pvc -n prometheus -o wide
```
### some commands 
```
kubectl get ns
```

# Premetheus

## 5. create prometheus.values
```
helm search prometheus
mkdir -p /vagrant/premetheus
helm inspect values stable/prometheus > /vagrant/prometheus/prometheus.values
```
Serach 
/server

service
/type 
type: NodePort
nodePort: 32322

/persistent
for 2Gi
server.persistentVolume.enabled: true
mountPath: /vagrant/prometheus/data2
existingClaim: "pvc-prometheus-pv1"

for 8Gi
server.persistentVolume.enabled: true
mountPath: /vagrant/prometheus/data2
existingClaim: "pvc-prometheus-pv2"
and 

## 6. Install prometheus
```
helm install stable/prometheus --name prometheus --values /vagrant/prometheus/prometheus.values --namespace prometheus
```

### some commands 

```
kubectl get all - prometheus
helm delete prometheus --purge

kubectl describe pod/prometheus-server-78db46bc7b-dz6h5 -n prometheus
kubectl logs prometheus-server-78db46bc7b-dz6h5 -c prometheus-server -n prometheus
```

## 7. open prometheus URL

```
http://10.0.0.5:32322/
```

# Grafana

## 8. create PV and PVC
```
kubectl create ns grafana
kubectl create -f /vagrant/grafana/pv-grafana-pv1.yaml --namespace grafana
kubectl create -f /vagrant/grafana/pvc-grafana-pv1.yaml --namespace grafana
```

## 9. create grafana.values

```
mkdir -p /vagrant/grafana
helm inspect values stable/grafana >/vagrant/grafana/grafana.values
```
edit
vi  /vagrant/grafana/grafana.values

service 
type: NodePort
nodePort: 32323

for 10Gi
persistence
enabled: true

existingClaim: pvc-grafana-pv1

adminPassword: admin


## 10.  Install Grafana

```
helm install stable/grafana --name grafana --values /vagrant/grafana/grafana.values --namespace grafana
```

### some commands
```
helm list 
helm delete grafana --purge
```

## 11. access grafana
```
http://10.0.0.5:32323/
```
enter password

on UI 
### add datasource -> 
select prpmetheus
url http://10.0.0.5:32322/
access (use server mode)
save and test

### Go Home

New dashboard
data source = prometheus

search grafana dashboard
select : Kubernetes Deployment Statefulset Daemonset metrics
get id : 10300

in UI -> click + icon and click import
select data source = prometheus

# clean up

```
helm delete grafana -- purge
helm delete prometheus --purge
kubectl delete pv
kubectl delete pvc 
kubectl delte nc grafana
kubectl delete ns prpmetheus
```

# Reference : 
- (vagrant) [https://stackoverflow.com/questions/7565446/change-vagrant-port-forwarding-on-a-running-system]
- (Grafana dashboard)[https://grafana.com/grafana/dashboards]
