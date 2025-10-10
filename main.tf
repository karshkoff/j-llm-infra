provider "aws" {
  region = var.region
}

# VPC for the infrastructure

module "network" {
  source      = "./modules/network"
  domain_name = "leazardlabs.site"
  tags        = var.tags
}

# EKS Cluster

module "eks" {
  source             = "./modules/eks"
  cluster_name       = "${var.tags.project}-eks-cluster"
  private_subnet_ids = module.network.private_subnet_ids
  tags               = var.tags
}

