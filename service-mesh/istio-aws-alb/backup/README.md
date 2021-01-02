#  Install Istio Service Mesh in an EKS Kubernetes Cluster 

Istio gateway to expose a service outside of the service mesh

[Service mesh](https://istio.io/latest/docs/concepts/what-is-istio/#what-is-a-service-mesh) manages communication between micriservices


[Istio](https://istio.io/latest/docs/concepts/what-is-istio/) is a service mesh implementation. Istio makes it easy to create a network of deployed services with load balancing, service-to-service authentication, monitoring, access control, traffic monitoring, security, discovery and many other useful features to services in a Kubernetes Cluster
There are no changes in  code to use these services. Istio does it all for you. 

[Istio Architecture](https://istio.io/latest/docs/ops/deployment/architecture/)

An Istio service mesh is logically split into a data plane and a control plane (version =>1.8.1)
Data plane - Sidecar envoy proxy
Control plane (Istiod)- inject proxy to each microservice POD

Microservice talk to each other using proxy.

configure and manage Istio using its control plane functionality, which includes:
- Traffic management: Automatic load balancing for HTTP, gRPC, WebSocket, and TCP traffic.
- Fine-grained control of traffic behavior with rich routing rules, retries, failovers, and fault injection.
- Observability: Automatic metrics, logs, and traces for all traffic within a cluster, including cluster ingress and egress.
- Security: Secure service-to-service communication in a cluster with strong identity-based authentication and authorization.
- Integration and customization: A pluggable policy layer and configuration API supporting access controls, rate limits and quotas.


## Pre-requisite
- Set up EKS CLuster [see quick-commands](https://github.com/koolkravi/kubernetes-playground/tree/master/cloud/aws/terraform-eks-cluster#quick-commands)

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

Read Install with Istioctl - [Prerequisite](https://istio.io/latest/docs/setup/install/istioctl/#prerequisites)

```
### Step 2: Create Istio Namespace

```
kubectl create namespace istio-system
```
### Step 3: Create required Secrets

I will install Grafana, Kiali and Jaeger as part of Istio installation. In our setup, each of these components requires credentials that must be provided as a Secret

Create these secrets in istio-system namespace
```
./1_Grafana-Secret.sh
./2_Kiali-Secret.sh
./3_Jaeger-Secret.sh

kubectl get secret -n istio-system
```

### Step 4: Perform any necessary [platform-specific setup](https://istio.io/latest/docs/setup/platform-setup/)
Create Istio Control Plane Configuration

```
istio-control-plane-eks.yml
```
Note: This file will contain the [Istio control plane spec](https://istio.io/docs/reference/config/istio.operator.v1alpha1/) details for configuring Istio
The contents are reference from  [Global Mesh Options](https://istio.io/latest/docs/reference/config/istio.mesh.v1alpha1/)


```
istioctl manifest apply -f istio-control-plane-eks.yml --dry-run      // Valiadte
istioctl manifest apply -f istio-control-plane-eks.yml                // Install istio
```

```
#Check deployed pods to confirm they are in running state
kubectl get pods -n istio-system

#Service Endpoints
kubectl get svc -n istio-system

#Add annotations to Ingress Service to get AWS Load Balancer. The annotations to be added are:
service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
service.beta.kubernetes.io/aws-load-balancer-internal: "0.0.0.0/0"

#add annotations with kubectl command
kubectl annotate svc istio-ingressgateway service.beta.kubernetes.io/aws-load-balancer-type="nlb" -n istio-system
kubectl annotate svc istio-ingressgateway service.beta.kubernetes.io/aws-load-balancer-internal="0.0.0.0/0" -n istio-system

#Confirm LB was created.
kubectl get svc istio-ingressgateway  -n istio-system
```

Accessing Dashboards

```
# Grafana
$ istioctl dashboard grafana

# Kiali
$ istioctl dashboard kiali

# Jaeger
$ istioctl dashboard jaeger

# Prometheus
$ istioctl dashboard prometheus

# Zipkin
$ istioctl dashboard zipkin

# Envoy
$ istioctl dashboard envoy <pod-name>.<namespace>
```
### Step 5: Configure Route53 DNS
### Step 6: Enable automatic sidecar injection for namespace
### Step 7: Deploy test Application with Istio gateway
Test access to the application with curl or Web browser

## Quick Commands

## Clean UP

## Reference
```
[Getting Started](https://istio.io/latest/docs/setup/getting-started/)
```

## Issues

