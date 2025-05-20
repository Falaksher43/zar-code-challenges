provider "aws" {
  region = var.region
}

# Configure Terraform state backend
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.10"
    }
  }
}

# VPC for EKS cluster
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"

  name                 = "${var.project_name}-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # Tags required for EKS
  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

# EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.24"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Managed node group defaults
  eks_managed_node_group_defaults = {
    disk_size      = 50
    instance_types = ["t3.medium"]
  }

  # EKS managed node groups
  eks_managed_node_groups = {
    general = {
      desired_size = 2
      min_size     = 1
      max_size     = 3

      labels = {
        role = "general"
      }
    }
  }

  # Configure OIDC provider for service accounts with IAM roles
  enable_irsa = true

  # Additional security group rules for the cluster
  cluster_security_group_additional_rules = {
    ingress_nodes_ephemeral_ports_tcp = {
      description                = "Nodes on ephemeral ports"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "ingress"
      source_node_security_group = true
    }
  }

  # Allow public access to the Kubernetes API
  cluster_endpoint_public_access = true

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Create ECR repository for the Flask app
resource "aws_ecr_repository" "flask_app" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}