
terraform {
    required_version = "~> 0.14.3" #as of 28/12/2020
}

# AWS Provider and Kubernetes Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.22.0" #as of 28/12/2020
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "1.13.3" #as of 28/12/2020
    }
  }
}
provider "aws" {
  region = var.region
}

# data sources
data "aws_eks_cluster" "cluster" {
    name = module.eks.cluster_id
}
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "aws_availability_zones" "available" {
  
}

# security groups for worker nodes

resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix        = "worker_group_mgmt_one"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    cidr_blocks = ["10.0.0.0/8"]
  }
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix        = "all_worker_mgmt"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    cidr_blocks = [
        "10.0.0.0/8",
        "172.16.0.0/12",
        "192.168.0.0/16"
    ]
  }
}

# create VPC using aws vpc module
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "2.64.0" #as of 28/12/2020
  name = "eks-cluster-vpc"
  cidr = "10.0.0.0/16"

  azs             = data.aws_availability_zones.available.names
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

}

# create EKS using aws eks module
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "13.2.1" #version of eks module as of 28/12/2020
  cluster_name    = var.cluster_name
  cluster_version = "1.18" # aws kubernetes version to run 
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id # tell eks module to what vpc to join
  cluster_create_timeout="1h"
  cluster_endpoint_private_access = true # This allow private endpoints to connect to kubetrnetes and join the cluster automatically
  
  # autoscaling worker group 
  worker_groups = [
    {
      name          = "worker-group-1"
      instance_type = "t2.small"
      asg_max_size  = 1
      worker_additional_security_group_ids=[aws_security_group.worker_group_mgmt_one.id]
    }
  ]

  worker_additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]

  # By default is cluster admin but
  # we can add extra role, extra users or extra accounts to allow to access to this cluster
  map_roles                            = var.map_roles
  map_users                            = var.map_users
  map_accounts                         = var.map_accounts

  # Deploying from Windows: /bin/sh file does not exist
  # ref: https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/faq.md#deploying-from-windows-binsh-file-does-not-exist
  # note comment below if you are running from linux OS
  wait_for_cluster_interpreter = ["C:/Program Files/Git/bin/sh.exe", "-c"]
}

# import and pass authentication details
# this allow to talk to eks cluster
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

