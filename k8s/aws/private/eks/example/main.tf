locals {
  region       = "us-east-1"
  cluster_name = "Private-EKS-Cluster"
}

data "aws_eks_cluster" "this" {
  name = local.cluster_name
}

provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.this.id, "--region", local.region]
  }
}

module "k8s" {
  source = "../"

  cluster_name = local.cluster_name
}

