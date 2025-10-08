provider "aws" {
  region = var.region
}

# Backend S3 bucket for Terraform state

module "storage" {
  source         = "./modules/storage"
  backend_bucket = "${var.tags.project}-tf-state-bucket"
  tags           = var.tags
}

# VPC for the infrastructure

module "network" {
  source = "./modules/network"
  tags   = var.tags
}

# EKS Cluster

module "eks" {
  source             = "./modules/eks"
  cluster_name       = "${var.tags.project}-eks-cluster"
  private_subnet_ids = module.network.private_subnet_ids
  tags               = var.tags
}

