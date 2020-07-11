#first install the cert-manager CustomResourceDefinition resource
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.15.2/cert-manager.crds.yaml


#nstall the chart
#kubectl create namespace cert-manager
helm repo add jetstack https://charts.jetstack.io

helm repo update
helm repo list


## Install the cert-manager helm chart
helm install --name cert-manager --namespace cert-manager jetstack/cert-manager --version v0.15.2 # --set installCRDs=true