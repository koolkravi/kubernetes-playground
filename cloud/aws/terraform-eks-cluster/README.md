# AWS EKS Infrastructure creation using Terraform and deploy nginx using terraform

We will create an EKS cluster using Terraform and deploy nginx ussing terraform

## Pre-requisite:
  ```
  Install docker desktop
  install aws cli 
  aws configure (Access Key ID,Secret Access Key)
  install kubectl 
  install iam authenticator (not needed)
  insall eksctl (not needed)
  Install Terraform-[see here](https://github.com/koolkravi/terraform-poc)
  ```

## Steps
we will do below using terraform
- Create Security groups, 
- VPC with public and priavte subnet   
- EKS CLuster with autoscaling groups for worker nodes
- k8s Deploy with 2 pods running nginx container
- k8s service of type load balancer to make nginx public 

## Step 1: Create terraform files
### Step 1.1. Create variable file
Variables allows to pass external inputs like secrets and configuratioin to terraform file
```
variables.tfvars
```

### Step 1.2. Create main file
This will contain all infrastructure for terraform e.g. vpc, eks cluster, security group etc. 
```
main.tf
```

### Step 1.3. Create outputs file
How to deploy something to this cluster once it is provision ? 
Define outputs, Everytime you deploy something as module, you can define outputs and pipe it to another module

when we create eks cluster, tell this module to output kubeconfig file to kubernetes module. SO that we can use kubernetes module to deploy application.
```
output.tf
```

### Step 1.4. add Kubernetes Provider 
[Kubernetes Provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs) 
Kubernetes Provider allows stuffs to deploy to kubernetes. 

```
add provider "kubernetes" into  main.tf
```

### Step 1.5. Create deployment file
Define a kubernetes_deployment and kubernetes_service 

This is similar to kubernetes yaml file but in terraform format
```
deployment.tf
```

## Step 2: Run 

```
cd kubernetes-playground\cloud\aws\terraform
terraform init # download all modules and plugings
terraform plan # what terraform do when we apply 
terraform apply #
```

## Step 3: Test  

Get EKS config
```
aws eks update-kubeconfig --name eks-cluster --region us-east-1
aws eks update-kubeconfig --name $(terraform output cluster_name) --region $(terraform output region) 

terraform output
kubectl get nodes
kubectl get deploy
kubectl get pods
kubectl get po --all-namespaces
kubectl get svc

open LB URL from browser and access ngnix : a030fb40938c64966885514f541ae8ef-473748140.us-east-1.elb.amazonaws.com
```

## Step 4: Clean Up

```
terraform destroy
```

## Quick commands
```
terraform init
terraform plan -out plan.out
terraform apply plan.out

aws configure
aws eks update-kubeconfig --name eks-cluster --region us-east-1

kubectl get nodes
kubectl get po --all-namespaces
kubectl get svc

LB URL : a030fb40938c64966885514f541ae8ef-473748140.us-east-1.elb.amazonaws.com

terraform destroy
```

## Reference : 
- [Terraform provider for AWS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [All the Kubernetes fields for terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster)
- AWS VPC Terraform module(https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)
- [Kubernetes Provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)

- Amazon CLI on [Docker-Hub](https://hub.docker.com/r/amazon/aws-cli)
### Another way to Run and Test : Get Amazon CLI on Docker-Hub
```
Note: Run below on Window machine from powershell

1. Run Amazon CLI 
#docker run -it --rm -v ${PWD}:/work -w /work --entrypoint /bin/sh amazon/aws-cli:2.0.43
docker run --rm -ti -v /C/Users/ravi_kumar27/.aws:/root/.aws -v /d/my_data4/5.study_material/kubernetes-playground/cloud/aws/terraform:/aws --entrypoint /bin/sh amazon/aws-cli


2. some handy tools

yum install -y jq gzip nano tar git unzip wget

3. aws configure

aws_access_key_id = XXXXXXXXXXXXXXXX
aws_secret_access_key = XXXXXXXXXXXXXXXX
region = us-east-1
output = json

4. Get Terraform

curl -o /tmp/terraform.zip -LO https://releases.hashicorp.com/terraform/0.14.3/terraform_0.14.3_linux_amd64.zip
unzip /tmp/terraform.zip
chmod +x terraform && mv terraform /usr/local/bin/
terraform

5. Run
cd kubernetes/cloud/amazon/terraform
terraform init
terraform plan
terraform apply

6. Get EKS config
aws eks update-kubeconfig --name eks-cluster --region us-east-1

7. Get kubectl

curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl

8. test

kubectl get nodes
kubectl get deploy
kubectl get pods
kubectl get po --all-namespaces
kubectl get svc

open LB URL from browser and access ngnix : a030fb40938c64966885514f541ae8ef-473748140.us-east-1.elb.amazonaws.com

9. Clean up
terraform destroy
```

## issues
```
Issue 1: Why are nodes not being registered?
Fix: add in vpc module enable_dns_hostnames = true
https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/faq.md#why-are-nodes-not-being-registered
https://github.com/terraform-aws-modules/terraform-aws-eks/issues/669

Issue 2: Deploying from Windows: /bin/sh file does not exist
Fix: https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/faq.md#deploying-from-windows-binsh-file-does-not-exist
module "eks" {
  # ...
  wait_for_cluster_interpreter = ["c:/git/bin/sh.exe", "-c"]
}
```