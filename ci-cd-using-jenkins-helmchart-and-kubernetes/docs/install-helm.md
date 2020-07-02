# Install Helm and tiller

## From the Binary Releases
1. Download your desired version
```
wget https://get.helm.sh/helm-v2.16.9-linux-amd64.tar.gz
```

2. Unpack it
```
tar -zxvf helm-v2.16.9-linux-amd64.tar.gz
```

3. Find the helm binary in the unpacked directory, and move it to its desired destination 
```
sudo mv linux-amd64/helm /usr/local/bin/helm
```

### Test

```
vagrant@k-master:~$ helm version
Client: &version.Version{SemVer:"v2.16.9", GitCommit:"8ad7037828e5a0fca1009dabe290130da6368e39", GitTreeState:"clean"}
Error: could not find tiller

vagrant@k-master:~$ helm version --short --client
Client: v2.16.9+g8ad7037
```

## Install  Tiller (Server side component of helm)

### Step 1: create service account tiller 
```
$ kubectl -n kube-system create serviceaccount tiller
serviceaccount/tiller created
```

### Step 2: create clusterrolebinding
```
$ kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
clusterrolebinding.rbac.authorization.k8s.io/tiller created
```
### commands to check 
```
$ kubectl get serviceaccount -n kube-system tiller
NAME     SECRETS   AGE
tiller   1         3m49s

$ kubectl get clusterrolebinding tiller
NAME     ROLE                        AGE
tiller   ClusterRole/cluster-admin   93s
```

## init helm
```
vagrant@k-master:~$ helm init --service-account tiller
```

### commands
```
$ kubectl  -n kube-system get pods
NAME                                       READY   STATUS    RESTARTS   AGE
calico-kube-controllers-59877c7fb4-4v4kw   1/1     Running   1          6h11m
calico-node-jk4z9                          1/1     Running   1          5h27m
calico-node-sw95n                          1/1     Running   1          6h11m
calico-node-tmf5q                          1/1     Running   1          5h52m
coredns-66bff467f8-b7lpm                   1/1     Running   1          6h11m
coredns-66bff467f8-ncm6w                   1/1     Running   1          6h11m
etcd-k-master                              1/1     Running   1          6h11m
kube-apiserver-k-master                    1/1     Running   1          6h11m
kube-controller-manager-k-master           1/1     Running   6          6h11m
kube-proxy-2hc9s                           1/1     Running   1          5h52m
kube-proxy-6g6qj                           1/1     Running   1          6h11m
kube-proxy-sgzcj                           1/1     Running   1          5h27m
kube-scheduler-k-master                    1/1     Running   6          6h11m
tiller-deploy-5d58456765-92k52             1/1     Running   0          53s
```

```
vagrant@k-master:~$ helm home
/home/vagrant/.helm

vagrant@k-master:~$ helm search jenkins
NAME            CHART VERSION   APP VERSION     DESCRIPTION
stable/jenkins  2.1.0           lts             Open source continuous integration server. It supports mu...

vagrant@k-master:~$ helm inspect stable/jenkins | less

vagrant@k-master:~$ helm fetch stable/jenkins

vagrant@k-master:~$ tar zxf jenkins-2.1.0.tgz

vagrant@k-master:~$ ls jenkins
CHANGELOG.md  Chart.yaml  OWNERS  README.md  templates  values.yaml


vagrant@k-master:~/jenkins$ ls jenkins/templates/
config.yaml             jenkins-backup-cronjob.yaml         jenkins-master-networkpolicy.yaml   rbac.yaml
deprecation.yaml        jenkins-backup-rbac.yaml            jenkins-master-route.yaml           secret-https-jks.yaml
_helpers.tpl            jenkins-master-alerting-rules.yaml  jenkins-master-servicemonitor.yaml  secret.yaml
home-pvc.yaml           jenkins-master-backendconfig.yaml   jenkins-master-svc.yaml             service-account-agent.yaml
jcasc-config.yaml       jenkins-master-deployment.yaml      jobs.yaml                           service-account.yaml
jenkins-agent-svc.yaml  jenkins-master-ingress.yaml         NOTES.txt                           tests

vagrant@k-master:~$ rm -rf jenkins jenkins-2.1.0.tgz

vagrant@k-master:~$ kubectl -n kube-system get deploy,replicaset,deployment,pod,serviceaccount,clusterrolebinding | grep tiller
deployment.apps/tiller-deploy             1/1     1            1           12m
replicaset.apps/tiller-deploy-5d58456765             1         1         1       12m
pod/tiller-deploy-5d58456765-92k52             1/1     Running   0          12m
serviceaccount/tiller                               1         20m
clusterrolebinding.rbac.authorization.k8s.io/tiller                                                 ClusterRole/cluster-admin                                                          18m

```

## Remove helm and clean 

```
vagrant@k-master:~$ helm reset --remove-helm-home
Deleting /home/vagrant/.helm

vagrant@k-master:~$ kubectl -n kube-system get deploy,replicaset,deployment,pod,serviceaccount,clusterrolebinding | grep tiller
serviceaccount/tiller                               1         22m
clusterrolebinding.rbac.authorization.k8s.io/tiller                                                 ClusterRole/cluster-admin                                                          21m
```

```
$ kubectl -n kube-system delete clusterrolebinding tiller
warning: deleting cluster-scoped resources, not scoped to the provided namespace
clusterrolebinding.rbac.authorization.k8s.io "tiller" deleted

$ kubectl -n kube-system delete serviceaccount tiller
serviceaccount "tiller" deleted

```

```
vagrant@k-master:~$ rm -rf helm-v2.16.9-linux-amd64.tar.gz linux-amd64/

vagrant@k-master:~$ sudo rm -rf /usr/local/bin/helm
```



# Ref:
- [Install  help](https://helm.sh/docs/intro/install/)
- 24, 25 
- https://github.com/helm/charts/tree/master/stable/jenkins