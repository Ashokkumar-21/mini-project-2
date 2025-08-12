terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = { source = "hashicorp/aws" }
    kubernetes = { source = "hashicorp/kubernetes"
    version = ">= 2.29.0" }
    helm = { source = "hashicorp/helm"
    version = ">= 2.14.0" }
    kubectl = { source = "gavinbunney/kubectl" }
  }
}

provider "aws" {
  region = var.aws_region
}
