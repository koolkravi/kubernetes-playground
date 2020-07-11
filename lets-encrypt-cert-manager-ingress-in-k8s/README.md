**Setup Lets Encrypt cert-manager in Kubernetes**

# Prerequisite

## 1. Provision kubernetes custer 
[vagrant-provisioning-kubeadm](https://github.com/koolkravi/kubernetes-playground/tree/master/vagrant-provisioning-kubeadm)

```
vagrant up
```

## 2. Install Helm, tiller and Setup private docker registry

[Execute README Step 2 ](https://github.com/koolkravi/kubernetes-playground/tree/master/ci-cd-using-jenkins-helmchart-and-kubernetes)

### some commands 
```
which helm
kubectl -n kube-system get pods
helm list
helm repo list
```

## 3. Change permission of docker.sock and run docker command without sudo

[Execute README Step 3 ](https://github.com/koolkravi/kubernetes-playground/tree/master/ci-cd-using-jenkins-helmchart-and-kubernetes)

# Lets Encrypt 

## 4. Install HA Proxy Load balancer
[See README Step 1 to 3] (https://github.com/koolkravi/kubernetes-playground/blob/master/practice-yaml/31-Setup-nginx-ingress-in-Kubernetes.md)

```
sudo apt-get updatesudo 
sudo apt-get -y install haproxy
haproxy -v
```

```
sudo vi /etc/haproxy/haproxy.cfg

#Add below at end of haproxy.cfg

frontend http_front
  bind *:443
  mode tcp
  option tcplog
  default_backend http_back

backend http_back
  mode tcp
  balance roundrobin
  server k-worker01 10.0.0.5:443
  server k-worker02 10.0.0.6:443
```

```
sudo systemctl status haproxy
sudo systemctl enable haproxy
sudo systemctl restart haproxy

sudo systemctl reload haproxy
sudo systemctl stop haproxy

netstat -nltp
```

## 5. Install NGINX Ingress Controller
[See README Step 4] (https://github.com/koolkravi/kubernetes-playground/blob/master/practice-yaml/31-Setup-nginx-ingress-in-Kubernetes.md)
#ref : https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-helm/

Execute below script
```
./install-nginx-Ingress-controller.sh
```

### some commands
```
kubectl get ns
kubectl -n nginx-ingress get all 
```

## 6. Install Cert Manager from Jet Stack Helm Repo
cert-manager is a Kubernetes addon to automate the management and issuance of TLS certificates from various issuing sources.
It will ensure certificates are valid and up to date periodically, and attempt to renew certificates at an appropriate time before expiry.

Go to helm hub and search for cert-manager (jetstack/cert-manager)
ref: https://hub.helm.sh/charts/jetstack/cert-manager
ref: https://cert-manager.io/docs/configuration/acme/
ref: https://cert-manager.io/docs/usage/ingress/
ref: https://cert-manager.io/docs/tutorials/acme/ingress/
ref: https://cert-manager.io/docs/installation/kubernetes/
Execute below script
```
./install-cert-manager.sh
```

### some commands
```
helm status cert-manager
#CustomResourceDefinition resource
kubectl get crds
kubectl get ns
kubectl -n cert-manager get all
```

## 7. Cluster Issuer
In order to begin issuing certificates, you will need to set up a ClusterIssuer or Issuer resource (for example, by creating a 'letsencrypt-staging' issuer).
Ref for different type of issuer: https://cert-manager.io/docs/configuration/

[Creating a Basic ACME Issuer] (https://cert-manager.io/docs/configuration/acme/)

```
kubectl create -f ClusterIssuer.yaml
kubectl get clusterIssuer
```

## 8. Create a sample Nginx deployment and expose as cluster IP Service 

```
kubectl create -f nginx-deployment.yaml
kubectl expose deploy nginx --port 80
kubectl get all
```

- service is of type Cluster IP so there is not access from external . 
- Usually we use node port or load balanceer to access from outside. yu can use service provider load balancer (azure/aws/google).
- you can also set up your own load balancer(metal LB) to access nginx. 
  [33-setup-metallb-load-balancing.md](https://github.com/koolkravi/kubernetes-playground/blob/master/practice-yaml/33-setup-metallb-load-balancing.md)

## 9. Deploy ingress resource 

```
kubectl create -f ingress-resource.yaml
kubectl get ing
kubectl describe ing ingress-resource
kubectl get certificates -o wide
kuberctl describe certificates letsencrypt-staging

kubectl delete ing ingress-resource
```

- Cluster issuer name "letsencrypt-staging" should match in ingress-resource annotations.

### Note
- Any request -> coming to Ingress controller for nginx.example.com -> will be routed to nginx service port 80
- TLS end point is on workert node on ingress controller
- users access IP address of LB on 443 https
- so connection between LB and worker node is encrypted using tls
- onnce conection comes into cluster, connection between ingress controller and service is on port 80 is not encrypted


## 10. update DNS

upadte hosts file of local machine with eblow

```
sudo vi /etc/hosts

#IP address of HAProxy LB machine
10.0.0.5 nginx.example.com
```

## 11. Testing
```
http://nginx.example.com/   -work 
https://nginx.example.com   - not work
```

# Clean Up
```
# Clean Up


kubectl delete ing ingress-resource
kubectl delete service nginx
kubectl delete deploy nginx

kubectl delete clusterIssuer letsencrypt-staging
helm delete cert-manager --purge
kubectl delete ns cert-manager

kubectl delete DaemonSet nginx-ingress -n nginx-ingress
kubectl delete ConfigMap nginx-config -n nginx-ingress
kubectl delete Secret default-server-secret -n nginx-ingress
kubectl delete ClusterRoleBinding nginx-ingress
kubectl delete ClusterRole nginx-ingress
kubectl delete serviceaccount nginx-ingress
kubectl delete namespace nginx-ingress
```


# Reference
- https://github.com/nginxinc/kubernetes-ingress
- https://hub.helm.sh/charts/jetstack/cert-manager
- https://cert-manager.io/docs/configuration/
