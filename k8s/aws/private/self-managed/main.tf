terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.18.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "4.57.1"
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
  service_account_name = "orca-scanner"
  namespace            = "orca-security"
  role_name            = "orca-scanner-role"
  role                 = var.orca_role_arn != "" ? var.orca_role_arn : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/OrcaSecurityRole"

  self_managed_cluster = {
    cluster_name          = data.local_file.cluster_name.content,
    cluster_type          = "k8s",
    api_server_endpoint   = data.local_file.api_server_url.content,
    service_account_token = kubernetes_secret_v1.this.data["token"]
  }
}

data "null_data_source" "api_server_url" {}

resource "null_resource" "get_api_server_url" {
  provisioner "local-exec" {
    command = "kubectl config view --minify --output 'jsonpath={.clusters[0].cluster.server}' > api_server_url.txt && kubectl config view --minify --output 'jsonpath={.contexts[0].context.cluster}' > cluster_name.txt"
  }

  depends_on = [data.null_data_source.api_server_url]
}

data "local_file" "api_server_url" {
  filename = "api_server_url.txt"
}

data "local_file" "cluster_name" {
  filename = "cluster_name.txt"
}