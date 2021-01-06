# NGINX Ingress Controller for Kubernetes 
Provide external access to multiple Kubernetes services in Amazon EKS cluster.
Ingress Controller is more efficient and cost-effective than a load balancer

- [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/): 
The Ingress is a Kubernetes resource that exposes HTTP and HTTPS routes from outside the cluster to the services within the cluster.

- [Ingress Controller](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/):
The Ingress Controller fulfills the ingress (usually with a load balancer). 

You can't use Ingress without an Ingress Controller.

## Steps 

I will use [nginxinc/kubernetes-ingress](https://github.com/nginxinc/kubernetes-ingress#getting-started) Ingress Controller. 

The other Ingress Controller available for public use is [kubernetes/ingress-nginx](https://github.com/kubernetes/ingress-nginx). 

see [Differences Between nginxinc/kubernetes-ingress and kubernetes/ingress-nginx Ingress Controllers](https://github.com/nginxinc/kubernetes-ingress/blob/master/docs/nginx-ingress-controllers.md)


### Step 1: Deploy the NGINX Ingress Controller for Kubernetes- Installation with Manifests

```
git clone https://github.com/nginxinc/kubernetes-ingress/
$ cd kubernetes-ingress/deployments
$ git checkout v1.9.1

kubectl apply -f common/ns-and-sa.yaml
kubectl apply -f rbac/rbac.yaml

kubectl apply -f common/default-server-secret.yaml
kubectl apply -f common/nginx-config.yaml

kubectl apply -f common/ingress-class.yaml // Create an IngressClass resource (for Kubernetes >= 1.18)

kubectl apply -f deployment/nginx-ingress.yaml
kubectl get pods --namespace=nginx-ingress
```
Your Ingress Controller can now accept requests from Ingress objects

### Step 2:  Access the Ingress Controller and run application

Create a service
```
kubectl apply -f service/loadbalancer-aws-elb.yaml
kubectl get svc --namespace=nginx-ingress
```

Note: Amazon EKS allocates a Classic Load Balancer in TCP mode with the PROXY protocol enabled to pass the client's information (the IP address and the port). You must pass this proxy information to the Ingress Controller.
NGINX must be configured to use the PROXY protocol

To configure NGINX to use the PROXY protocol so that you can pass proxy information to the Ingress Controller, add the following keys to the nginx-config.yaml in Step 1
```
kind: ConfigMap
apiVersion: v1
metadata:
  name: nginx-config
  namespace: nginx-ingress
data:
  proxy-protocol: "True"
  real-ip-header: "proxy_protocol"
  set-real-ip-from: "0.0.0.0/0"
```
Note: The proxy information is passed to the Ingress Controller through the ConfigMap that you created earlier.

Update the config map
```
kubectl apply -f common/nginx-config.yaml
```

```
Note:  public IP of the load balancer to access the Ingress controller. To get the public IP:
kubectl describe svc nginx-ingress --namespace=nginx-ingress
nslookup <dns-name>
```

### Step 3: Set up deployments or microservices (for example, hostname-app and apache-app).

Example for hostname-app and apache-app, See hostname-app-svc.yaml and  apache-app-svc.yaml

```
kubectl apply -f hostname-app-svc.yaml
kubectl apply -f apache-app-svc.yaml
```
### 4 : Implement Ingress so that it interfaces with your services using a single load balancer provided by Ingress Controller. 
See micro-ingress.yaml

```
kubectl apply -f micro-ingress.yaml
```

Note: This Ingress resource defines rules that redirect anything for hostname.mydomain.com to hostname-svc, and anything for apache.mydomain.com to apache-svc. Any request that doesn't match the rule returns a 404 "Not Found" error message.

### 5 : Test the NGINX Ingress Controller

To Get LB run below
```
kubectl get svc --namespace=nginx-ingress
```

* To access the DNS URL of the load balancer from the command line, run the following command

```
curl -I http://aaa71bxxxxx-11xxxxx10.us-east-1.elb.amazonaws.com/
or 
curl -kivL http://a805b8d3239f9408d81ec427b53d8f55-595912430.us-east-1.elb.amazonaws.com/

return 404
```
Note: The load balancer endpoint is from the preceding Access the Ingress Controller and run application section.

Note: The default server returns a "Not Found" page with a 404 status code for all the requests for domains where no Ingress rules are defined. The Ingress Controller, based on the defined rules, doesn't divert traffic to the specified backend service, unless the request matches with the configuration. Because the host field is configured for the Ingress object, you must supply the Host header of the request with the same hostname.

* Add the Host header to the request.

* This is a request based on the first configured domain
```
curl -I -H "Host: hostname.mydomain.com" http://aaa25a5010daa11eaa41e121e71bd6ca-113564610.us-east-1.elb.amazonaws.com/
or
curl -kivLI -H "Host: hostname.mydomain.com" http://a805b8d3239f9408d81ec427b53d8f55-595912430.us-east-1.elb.amazonaws.com/

return 200
```

* This is a request based on the second configured domain:
```
curl -I -H "Host: apache.mydomain.com" http://aaa25a5010daa11eaa41e121e71bd6ca-113564610.us-east-1.elb.amazonaws.com/
or
curl -kivL -H "Host: apache.mydomain.com" http://a805b8d3239f9408d81ec427b53d8f55-595912430.us-east-1.elb.amazonaws.com/

return 200
```
After you add the Host header, the Ingress Controller can redirect traffic to the backend configured service as it matches the configuration defined in Ingress.

Note: 
* If you want to keep the same domain name, but divert the traffic based on the path accessed, you must add path-based routing with Ingress. 
For example:
```
micro-ingress-path-based.yaml
kubectl apply -f micro-ingress.yaml
```

The preceding example returns only the 200 response when requests have hostname.mydomain.com as the host header. The requests are accessed on either the /login or /cart paths. For all other requests, 404 responses are returned.

## Quick Commands
```
git clone https://github.com/nginxinc/kubernetes-ingress/
$ cd kubernetes-ingress/deployments
$ git checkout v1.9.1

kubectl apply -f common/ns-and-sa.yaml
kubectl apply -f rbac/rbac.yaml

kubectl apply -f common/default-server-secret.yaml
kubectl apply -f common/nginx-config.yaml
kubectl apply -f common/ingress-class.yaml

kubectl apply -f deployment/nginx-ingress.yaml
kubectl get pods --namespace=nginx-ingress

kubectl apply -f service/loadbalancer-aws-elb.yaml
kubectl get svc --namespace=nginx-ingress

Update the common/nginx-config.yaml

data:
  proxy-protocol: "True"
  real-ip-header: "proxy_protocol"
  set-real-ip-from: "0.0.0.0/0"
  
kubectl apply -f common/nginx-config.yaml

kubectl apply -f hostname-app-svc.yaml
kubectl apply -f apache-app-svc.yaml
kubectl apply -f micro-ingress.yaml

kubectl describe ing  micro-ingress

Get LB :  kubectl get svc --namespace=nginx-ingress

curl -kivL http://a805b8d3239f9408d81ec427b53d8f55-595912430.us-east-1.elb.amazonaws.com/

curl -kivLI -H "Host: hostname.mydomain.com" http://a805b8d3239f9408d81ec427b53d8f55-595912430.us-east-1.elb.amazonaws.com/

curl -kivL -H "Host: apache.mydomain.com" http://a805b8d3239f9408d81ec427b53d8f55-595912430.us-east-1.elb.amazonaws.com/

micro-ingress-path-based.yaml
kubectl apply -f micro-ingress.yaml
```

## Clean UP
### Uninstall the Ingress Controller
```
kubectl delete namespace nginx-ingress
kubectl delete clusterrole nginx-ingress
kubectl delete clusterrolebinding nginx-ingress
```

## Reference
- [nginxinc/kubernetes-ingress](https://github.com/nginxinc/kubernetes-ingress#getting-started) 

## Issues
```
Issue 1: run kubectl apply -f common/ingress-class.yaml else ingress controller pod crashloopbackoff

https://stackoverflow.com/questions/64098770/back-off-restarting-failed-container-kubernetes

Issue 2: add below in micro-ingress.yaml else ingress routing does not work
annotations:
    kubernetes.io/ingress.class: "nginx"
```
