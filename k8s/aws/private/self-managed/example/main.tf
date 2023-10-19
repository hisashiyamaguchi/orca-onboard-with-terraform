provider "aws" {
  region = "us-east-1"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

module "self" {
  source = "../"

  lambda_subnet_ids         = ["subnet-08db10d809024e655"]
  lambda_security_group_ids = ["sg-01b3dde79d84d18c6"]
}


output "self_managed_cluster" {
  value     = module.self.self_managed_cluster
  sensitive = true
}
