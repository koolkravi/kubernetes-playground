# 1
```
choco install kubernetes-helm
Chocolatey v0.10.15
Chocolatey detected you are not running from an elevated command shell
 (cmd/powershell).

 You may experience errors - many functions/packages
 require admin rights. Only advanced users should run choco w/out an
 elevated shell. When you open the command shell, you should ensure
 that you do so with "Run as Administrator" selected. If you are
 must select a different location other than the default install
 location. See
 https://chocolatey.org/install#non-administrative-install for details.




 Do you want to continue?([Y]es/[N]o): yes

Installing the following packages:
kubernetes-helm
By installing you accept licenses for the packages.
kubernetes-helm v3.3.4 already installed.
 Use --force to reinstall, specify a version to install, or try upgrade.

Chocolatey installed 0/1 packages.
 See the log for details (C:\ProgramData\chocolatey\logs\chocolatey.log).

Warnings:
 - kubernetes-helm - kubernetes-helm v3.3.4 already installed.
 Use --force to reinstall, specify a version to install, or try upgrade.
```

# 2.
```
 choco upgrade kubernetes-helm
Chocolatey v0.10.15
Upgrading the following packages:
kubernetes-helm
By upgrading you accept licenses for the packages.

You have kubernetes-helm v3.3.4 installed. Version 3.4.2 is available based on your source(s).
Progress: Downloading kubernetes-helm 3.4.2... 100%

kubernetes-helm v3.4.2 [Approved]
kubernetes-helm package files upgrade completed. Performing other installation steps.
The package kubernetes-helm wants to run 'chocolateyInstall.ps1'.
Note: If you don't run this script, the installation will fail.
Note: To confirm automatically next time, use '-y' or consider:
choco feature enable -n allowGlobalConfirmation
Do you want to run the script?([Y]es/[A]ll - yes to all/[N]o/[P]rint): yes

Downloading kubernetes-helm 64 bit
  from 'https://get.helm.sh/helm-v3.4.2-windows-amd64.zip'
Progress: 100% - Completed download of C:\Users\ravi_kumar27\AppData\Local\Temp\chocolatey\kubernetes-helm\3.4.2\helm-v3.4.2-windows-amd64.zip (12.68 MB).
Download of helm-v3.4.2-windows-amd64.zip (12.68 MB) completed.
Hashes match.
Extracting C:\Users\ravi_kumar27\AppData\Local\Temp\chocolatey\kubernetes-helm\3.4.2\helm-v3.4.2-windows-amd64.zip to C:\ProgramData\chocolatey\lib\kubernetes-helm\tools...
C:\ProgramData\chocolatey\lib\kubernetes-helm\tools
 ShimGen has successfully created a shim for helm.exe
 The upgrade of kubernetes-helm was successful.
  Software installed to 'C:\ProgramData\chocolatey\lib\kubernetes-helm\tools'

Chocolatey upgraded 1/1 packages.
 See the log for details (C:\ProgramData\chocolatey\logs\chocolatey.log).
```
# 3. helm version
```
helm version        
WARNING: "kubernetes-charts.storage.googleapis.com" is deprecated for "stable" and will be deleted Nov. 13, 2020.
WARNING: You should switch to "https://charts.helm.sh/stable" via:
WARNING: helm repo add "stable" "https://charts.helm.sh/stable" --force-update
version.BuildInfo{Version:"v3.4.2", GitCommit:"23dd3af5e19a02d4f4baa5b2f242645a1a3af629", GitTreeState:"clean", GoVersion:"go1.14.13"}
```

# 4. uninstall and install 
```
choco install kubernetes-helm
Chocolatey v0.10.15
Installing the following packages:
kubernetes-helm
By installing you accept licenses for the packages.
Progress: Downloading kubernetes-helm 3.4.2... 100%

kubernetes-helm v3.4.2 [Approved]
kubernetes-helm package files install completed. Performing other installation steps.
The package kubernetes-helm wants to run 'chocolateyInstall.ps1'.
Note: If you don't run this script, the installation will fail.
Note: To confirm automatically next time, use '-y' or consider:
choco feature enable -n allowGlobalConfirmation
You must select an answer
Do you want to run the script?([Y]es/[A]ll - yes to all/[N]o/[P]rint): yes

Downloading kubernetes-helm 64 bit
  from 'https://get.helm.sh/helm-v3.4.2-windows-amd64.zip'
Progress: 100% - Completed download of C:\Users\ravi_kumar27\AppData\Local\Temp\chocolatey\kubernetes-helm\3.4.2\helm-v3.4.2-windows-amd64.zip (12.68 MB).
Download of helm-v3.4.2-windows-amd64.zip (12.68 MB) completed.
Hashes match.
Extracting C:\Users\ravi_kumar27\AppData\Local\Temp\chocolatey\kubernetes-helm\3.4.2\helm-v3.4.2-windows-amd64.zip to C:\ProgramData\chocolatey\lib\kubernetes-helm\tools...
C:\ProgramData\chocolatey\lib\kubernetes-helm\tools
 ShimGen has successfully created a shim for helm.exe
 The install of kubernetes-helm was successful.
  Software installed to 'C:\ProgramData\chocolatey\lib\kubernetes-helm\tools'

  ```
# 5.
```
helm version
WARNING: "kubernetes-charts.storage.googleapis.com" is deprecated for "stable" and will be deleted Nov. 13, 2020.
WARNING: You should switch to "https://charts.helm.sh/stable" via:
WARNING: helm repo add "stable" "https://charts.helm.sh/stable" --force-update
version.BuildInfo{Version:"v3.4.2", GitCommit:"23dd3af5e19a02d4f4baa5b2f242645a1a3af629", GitTreeState:"clean", GoVersion:"go1.14.13"}
```
# 6. 
```
helm version        
version.BuildInfo{Version:"v3.4.2", GitCommit:"23dd3af5e19a02d4f4baa5b2f242645a1a3af629", GitTreeState:"clean", GoVersion:"go1.14.13"}
```

# 7.
```
istioctl version
no running Istio pods in "istio-system"
1.8.1
```

# 8
```
istioctl help 
Istio configuration command line utility for service operators to
debug and diagnose their Istio mesh.

Usage:
  istioctl [command]

Available Commands:
  analyze         Analyze Istio configuration and print validation messages
  authz           (authz is experimental. Use `istioctl experimental authz`)
  bug-report      Cluster information and log capture support tool.
  convert-ingress Convert Ingress configuration into Istio VirtualService configuration [Deprecated, it will be removed in Istio 1.9]
  dashboard       Access to Istio web UIs
  deregister      De-registers a service instance [Deprecated, it will be removed in Istio 1.9]
  experimental    Experimental commands that may be modified or deprecated
  help            Help about any command
  install         Applies an Istio manifest, installing or reconfiguring Istio on a cluster.
  kube-inject     Inject Envoy sidecar into Kubernetes pod resources
  manifest        Commands related to Istio manifests
  operator        Commands related to Istio operator controller.
  profile         Commands related to Istio configuration profiles
  proxy-config    Retrieve information about proxy configuration from Envoy [kube only]
  proxy-status    Retrieves the synchronization status of each Envoy in the mesh [kube only]
  register        Registers a service instance (e.g. VM) joining the mesh [Deprecated, it will be removed in Istio 1.9]
  upgrade         Upgrade Istio control plane in-place
  validate        Validate Istio policy and rules files
  verify-install  Verifies Istio Installation Status
  version         Prints out build version information

Flags:
PS D:\my_data4\5.study_material\kubernetes-playground\service-mesh> istioctl help
Istio configuration command line utility for service operators to
debug and diagnose their Istio mesh.

Usage:
  istioctl [command]

Available Commands:
  analyze         Analyze Istio configuration and print validation messages 
  authz           (authz is experimental. Use `istioctl experimental authz`)
  bug-report      Cluster information and log capture support tool.
  convert-ingress Convert Ingress configuration into Istio VirtualService configuration [Deprecated, it will be removed in Istio 1.9]
  dashboard       Access to Istio web UIs
  deregister      De-registers a service instance [Deprecated, it will be removed in Istio 1.9]
  experimental    Experimental commands that may be modified or deprecated
  help            Help about any command
  install         Applies an Istio manifest, installing or reconfiguring Istio on a cluster.
  kube-inject     Inject Envoy sidecar into Kubernetes pod resources
  manifest        Commands related to Istio manifests
  operator        Commands related to Istio operator controller.
  profile         Commands related to Istio configuration profiles
  proxy-config    Retrieve information about proxy configuration from Envoy [kube only]
  proxy-status    Retrieves the synchronization status of each Envoy in the mesh [kube only]
  register        Registers a service instance (e.g. VM) joining the mesh [Deprecated, it will be removed in Istio 1.9]
  upgrade         Upgrade Istio control plane in-place
  validate        Validate Istio policy and rules files
  verify-install  Verifies Istio Installation Status
  version         Prints out build version information

Flags:
      --context string          The name of the kubeconfig context to use
  -h, --help                    help for istioctl
  -i, --istioNamespace string   Istio system namespace (default "istio-system")
  -c, --kubeconfig string       Kubernetes configuration file
  -n, --namespace string        Config namespace

Additional help topics:
  istioctl options         Displays istioctl global options

Use "istioctl [command] --help" for more information about a command.

```
# 9
```
choco install jq
Chocolatey v0.10.15
Installing the following packages:
jq
By installing you accept licenses for the packages.
Progress: Downloading jq 1.6... 100%

jq v1.6 [Approved]
jq package files install completed. Performing other installation steps.
The package jq wants to run 'chocolateyinstall.ps1'.
Note: If you don't run this script, the installation will fail.
Note: To confirm automatically next time, use '-y' or consider:
choco feature enable -n allowGlobalConfirmation
Do you want to run the script?([Y]es/[A]ll - yes to all/[N]o/[P]rint): yes

Downloading jq 64 bit
  from 'https://github.com/stedolan/jq/releases/download/jq-1.6/jq-win64.exe'
Progress: 100% - Completed download of C:\ProgramData\chocolatey\lib\jq\tools\jq.exe (3.36 MB).
Download of jq.exe (3.36 MB) completed.
Hashes match.
C:\ProgramData\chocolatey\lib\jq\tools\jq.exe
 ShimGen has successfully created a shim for jq.exe
 The install of jq was successful.
  Software install location not explicitly set, could be in package or
  default install location if installer.

Chocolatey installed 1/1 packages.
 See the log for details (C:\ProgramData\chocolatey\logs\chocolatey.log).
```
# 10
```
istioctl verify-install
Error: could not load IstioOperator from cluster: the server could not find the requested resource.  Use --filename
```

# 11
```
kubectl get --raw /api/v1 | jq '.resources[] | select(.name | index("serviceaccounts/token"))'
jq: error: serviceaccounts/0 is not defined at <top-level>, line 1:
.resources[] | select(.name | index(serviceaccounts/token))
jq: error: token/0 is not defined at <top-level>, line 1:
.resources[] | select(.name | index(serviceaccounts/token))
jq: 2 compile errors
```

# 12
```
 istioctl experimental precheck
Istio already installed in namespace "istio-system".  Skipping pre-check.  Confirm with 'istioctl verify-install'.
Use 'istioctl upgrade' to upgrade or 'istioctl install --set revision=<revision>' to install another control plane.

```
# 12.
```
kubectl create namespace istio-system
namespace/istio-system created
```

# 13. 

```
$ helm install -n istio-system istio-base manifests/charts/base
Error: rendered manifests contain a resource that already exists. Unable to continue with install: ClusterRole "istiod-istio-system" in namespace "" exists and cannot be imported into the current release: invalid ownership metadata; label validation error: missing key "app.kubernetes.io/managed-by": must be set to "Helm"; annotation validation error: missing key "meta.helm.sh/release-name": must be set to "istio-base"; annotation validation error: missing key "meta.helm.sh/release-namespace": must be set to "istio-system"

```

# 14
```
 istioctl operator init
Installing operator controller in namespace: istio-operator using image: docker.io/istio/operator:1.8.1
Operator controller will watch namespaces: istio-system
Ô£ö Istio operator installed                                                                                                                                                             
Ô£ö Installation complete

```

```
kubectl get all -n istio-operator
NAME                                  READY   STATUS    RESTARTS   AGE
pod/istio-operator-5849779c6b-bsldc   1/1     Running   0          2m17s

NAME                     TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
service/istio-operator   ClusterIP   172.20.199.0   <none>        8383/TCP   2m16s

NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/istio-operator   1/1     1            1           2m18s

NAME                                        DESIRED   CURRENT   READY   AGE
replicaset.apps/istio-operator-5849779c6b   1         1         1       2m18s
```
```
$ kubectl apply -f - <<EOF
> apiVersion: install.istio.io/v1alpha1
> kind: IstioOperator
> metadata:
>   namespace: istio-system
>   name: example-istiocontrolplane
> spec:
>   profile: demo
> EOF
istiooperator.install.istio.io/example-istiocontrolplane created

```

```
kubectl get svc -n istio-system
NAME                   TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)
                                                           AGE
istio-egressgateway    ClusterIP      172.20.151.102   <none>                                                                    80/TCP,443/TCP,15443/TCP                                                     2m37s
istio-ingressgateway   LoadBalancer   172.20.105.160   aa1b95d70e36a46c79a068ba3c6c2561-2065806133.us-east-1.elb.amazonaws.com   15021:31211/TCP,80:31405/TCP,443:30041/TCP,31400:31548/TCP,15443:30980/TCP   2m37s
istiod                 ClusterIP      172.20.244.49    <none>                                                                    15010/TCP,15012/TCP,443/TCP,15014/TCP                                        2m45s
```


```
$ kubectl get all -n istio-system
NAME                                        READY   STATUS        RESTARTS   AGE
pod/istio-egressgateway-69fc79d576-kfv54    0/1     Terminating   0          14m
pod/istio-ingressgateway-7576658c9b-pbp9j   1/1     Running       0          17s
pod/istio-ingressgateway-bc9b55659-xdx6z    0/1     Terminating   0          14m
pod/istiod-67f5756967-8rgkh                 1/1     Running       0          14m
pod/istiod-c85d85ddd-j4p4s                  0/1     Pending       0          5m17s

NAME                           TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)                                                                      AGE
service/istio-ingressgateway   LoadBalancer   172.20.105.160   aa1b95d70e36a46c79a068ba3c6c2561-2065806133.us-east-1.elb.amazonaws.com   15021:31964/TCP,80:32395/TCP,443:31757/TCP,15012:31384/TCP,15443:31113/TCP   14m
service/istiod                 ClusterIP      172.20.244.49    <none>                                                                    15010/TCP,15012/TCP,443/TCP,15014/TCP                                        14m

NAME                                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/istio-ingressgateway   1/1     1            1           14m
deployment.apps/istiod                 1/1     1            1           14m

NAME                                              DESIRED   CURRENT   READY   AGE
replicaset.apps/istio-ingressgateway-7576658c9b   1         1         1       18s
replicaset.apps/istio-ingressgateway-bc9b55659    0         0         0       14m
replicaset.apps/istiod-67f5756967                 1         1         1       14m
replicaset.apps/istiod-c85d85ddd                  1         1         0       5m18s

NAME                                                       REFERENCE                         TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/istio-ingressgateway   Deployment/istio-ingressgateway   <unknown>/80%   1         5         1          18s
horizontalpodautoscaler.autoscaling/istiod                 Deployment/istiod                 <unknown>/80%   1         5         1          5m18s

```

```
$ kubectl get all -n istio-operator
NAME                                  READY   STATUS    RESTARTS   AGE
pod/istio-operator-5849779c6b-bsldc   1/1     Running   0          23m

NAME                     TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
service/istio-operator   ClusterIP   172.20.199.0   <none>        8383/TCP   23m

NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/istio-operator   1/1     1            1           23m

NAME                                        DESIRED   CURRENT   READY   AGE
replicaset.apps/istio-operator-5849779c6b   1         1         1       23m
```

```
$ kubectl get crds
NAME                                         CREATED AT
authorizationpolicies.security.istio.io      2021-01-02T11:34:47Z
destinationrules.networking.istio.io         2021-01-02T11:34:48Z
eniconfigs.crd.k8s.amazonaws.com             2021-01-02T10:00:36Z
envoyfilters.networking.istio.io             2021-01-02T11:34:48Z
gateways.networking.istio.io                 2021-01-02T11:34:48Z
istiooperators.install.istio.io              2021-01-02T11:34:49Z
peerauthentications.security.istio.io        2021-01-02T11:34:49Z
requestauthentications.security.istio.io     2021-01-02T11:34:49Z
securitygrouppolicies.vpcresources.k8s.aws   2021-01-02T10:00:39Z
serviceentries.networking.istio.io           2021-01-02T11:34:50Z
sidecars.networking.istio.io                 2021-01-02T11:34:50Z
virtualservices.networking.istio.io          2021-01-02T11:34:50Z
workloadentries.networking.istio.io          2021-01-02T11:34:51Z
workloadgroups.networking.istio.io           2021-01-02T11:34:51Z

```
```
$ kubectl get crds | grep istio | wc -l
12
```