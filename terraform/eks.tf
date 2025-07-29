terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region = var.region_name
}

# IAM Role for EKS Managed Node Group
data "aws_iam_policy_document" "eks_node_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_node_group_role" {
  name               = "eks-node-group-role"
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "eks_worker_node" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ])
  policy_arn = each.key
  role       = aws_iam_role.eks_node_group_role.name
}

# EKS Cluster Module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = "musician-app-cluster"
  cluster_version = "1.31"

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  vpc_id = "vpc-0e40c5361404fb269"
  subnet_ids = [
    "subnet-0acb823a59c31e156",
    "subnet-06e64fbdbfe472925",
    "subnet-087fd0194978d0fb3"
  ]

  eks_managed_node_groups = {
    default = {
      instance_types = ["t2.medium"]
      desired_size   = 2
      min_size       = 1
      max_size       = 3
      ami_type       = "AL2023_x86_64_STANDARD"
      iam_role_arn   = aws_iam_role.eks_node_group_role.arn
    }
  }

  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
