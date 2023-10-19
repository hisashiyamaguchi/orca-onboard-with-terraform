
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.57.1"
    }
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.this.id, "--region", data.aws_region.current.name]
  }
}

locals {
  role = var.orca_role_arn != "" ? var.orca_role_arn : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/OrcaSecurityRole"
}