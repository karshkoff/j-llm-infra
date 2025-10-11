terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.16"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
  }

  required_version = ">= 1.13"

  backend "s3" {}
}
