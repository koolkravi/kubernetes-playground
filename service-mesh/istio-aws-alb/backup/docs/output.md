# 1.
$ istioctl version
unable to retrieve Pods: Get "https://F7F1EF6AAEC8D7E4CD2A3F62CB34D92F.gr7.us-east-1.eks.amazonaws.com/api/v1/namespaces/istio-system/pods?fieldSelector=status.phase%3DRunning&labelSelector=app%3Distiod": dial tcp: lookup F7F1EF6AAEC8D7E4CD2A3F62CB34D92F.gr7.us-east-1.eks.amazonaws.com: no such host
1.8.1

# after EKS cluser setup done
$ istioctl version
no running Istio pods in "istio-system"
1.8.1

# 2. 
$ ./1_Grafana-Secret.sh
secret/grafana created

$ ./2_Kiali-Secret.sh
secret/kiali created

$ ./3_Jaeger-Secret.sh
secret/jaeger created

# 3. 
$ kubectl get secret -n istio-system
NAME                  TYPE                                  DATA   AGE
default-token-hmkbt   kubernetes.io/service-account-token   3      20m
grafana               Opaque                                2      4m41s
jaeger                Opaque                                2      3m57s
kiali                 Opaque                                2      2m9s


# 4 error
$ istioctl manifest apply -f istio-control-plane-eks.yml --dry-run
Error: unknown shorthand flag: 'f' in -f


