#  Install Istio Service Mesh in an EKS Kubernetes Cluster 

Istio gateway to expose a service outside of the service mesh

[Service mesh](https://istio.io/latest/docs/concepts/what-is-istio/#what-is-a-service-mesh) manages communication between micriservices


[Istio](https://istio.io/latest/docs/concepts/what-is-istio/) is a service mesh implementation. Istio makes it easy to create a network of deployed services with load balancing, service-to-service authentication, monitoring, access control, traffic monitoring, security, discovery and many other useful features to services in a Kubernetes Cluster
There are no changes in  code to use these services. Istio does it all for you. 



[Istio Architecture](https://istio.io/latest/docs/ops/deployment/architecture/)

An Istio service mesh is logically split into a data plane and a control plane (version =>1.8.1)
Data plane - Sidecar envoy proxy
Control plane (Istiod)- inject envoy proxy to each microservice POD
Microservice talk to each other using proxy.


Why we need ?
- Trafic Management
- Authentication between services
- Authorization between services
- Secure services between services
- Observability
    - Tracing 
    - monitoring
    - logging 

- Others
    - Service discovery
    - Load balancing 



## Pre-requisite
### 1. Set up EKS CLuster [see quick-commands](https://github.com/koolkravi/kubernetes-playground/tree/master/cloud/aws/terraform-eks-cluster#quick-commands)

```
aws eks update-kubeconfig --name eks-cluster --region us-east-1
```

### 2. install helm 3 - The package manager for Kubernetes
```
[Quickstart](https://helm.sh/docs/intro/quickstart/)

a. [Installing Helm](https://helm.sh/docs/intro/install/) Through Package Managers From Chocolatey (Windows)

choco uninstall kubernetes-helm
choco install kubernetes-helm
helm version --short
#choco upgrade kubernetes-helm


b. Initialize a Helm Chart Repository
helm repo add "stable" "https://charts.helm.sh/stable" --force-update
helm search repo stable
```

## Steps 
### Step 1:  Install istioctl in Local machine / Bastion Host

[See Installation Guides](https://istio.io/latest/docs/setup/install/)
[which Istio installation method should I use](https://istio.io/latest/faq/setup/#install-method-selection)

[Download Istio](https://istio.io/latest/docs/setup/getting-started/#download) and Install with Istioctl

```
Download below for window 10
https://github.com/istio/istio/releases/download/1.8.1/istio-1.8.1-win.zip
https://github.com/istio/istio/releases/download/1.8.1/istioctl-1.8.1-win.zip

Note: The istioctl client binary in the bin/ directory. Set this into path
istioctl version
istioctl help



Read Install with Istioctl - [Prerequisite](https://istio.io/latest/docs/setup/install/istioctl/#prerequisites)
```

### Step 2: Istio installation Options 
### Option 2a: [Install with Helm](https://istio.io/latest/docs/setup/install/helm/) - DoesNot work ???

[Verify that Istio can be installed](https://istio.io/latest/docs/reference/commands/istioctl/#istioctl-experimental-precheck) with my current version of Kubernetes

```
istioctl experimental precheck
istioctl verify-install
```
[Istio Installation Guides](https://istio.io/latest/docs/setup/install/)

```
choco install jq
```
Verify if third party tokens are enabled in your cluster by following the steps describe [here]
```
kubectl get --raw /api/v1 | jq '.resources[] | select(.name | index("serviceaccounts/token"))'
```
If third party tokens are not enabled, you should add the option --set global.jwtPolicy=first-party-jwt to the Helm install commands
If the jwtPolicy is not set correctly, pods associated with istiod, gateways or workloads with injected Envoy proxies will not get deployed due to the missing istio-token volume.

```
cd C:\bin\istio-1.8.1 // contains manifests
kubectl create namespace istio-system
helm install -n istio-system istio-base manifests/charts/base --set global.jwtPolicy=first-party-jwt
```

### Option 2b:  [Install with Istioctl](https://istio.io/latest/docs/setup/install/istioctl/) - DOES NOT WORK ????

```
#Install Istio using the default profile
istioctl install

```

### Option 2c: [Istio Operator Install](https://istio.io/latest/docs/setup/install/operator/)  - Work
```
kubectl create ns istio-system

kubectl apply -f - <<EOF
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  namespace: istio-system
  name: example-istiocontrolplane
spec:
  profile: demo
EOF

```
Confirm the Istio control plane services have been deployed with the following commands
```
kubectl get svc -n istio-system
```

switch the installation to the default profile

```
kubectl apply -f - <<EOF
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  namespace: istio-system
  name: example-istiocontrolplane
spec:
  profile: default
EOF
```

```
kubectl get crds | grep istio

kubectl get crds | grep istio | wc -l 
```
 
 Run below to get load balancer URL
 ```
 kubectl get svc -n istio-system
 ```

### Step 3: [Deploy the sample application](https://istio.io/latest/docs/setup/getting-started/#bookinfo)


```
http://aa1b95d70e36a46c79a068ba3c6c2561-2065806133.us-east-1.elb.amazonaws.com/productpage
```



## Quick Commands

## Clean UP

## Reference

## Issues

```
Issue 1: Install with Helm and  Install with Istioctl not working

https://stackoverflow.com/questions/62512048/could-not-install-istio-1-6-3-demo-profile-on-aws-eks
```