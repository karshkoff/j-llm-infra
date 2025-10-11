provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
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
  cluster_name       = var.tags.project
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  aws_account_id     = local.aws_account_id
  tags               = var.tags
}

