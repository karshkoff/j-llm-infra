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

