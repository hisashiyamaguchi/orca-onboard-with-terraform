################################################################################
#                               aws-auth configmap                             #
################################################################################

locals {
  user_name = "orca-scanner"
  namespace = "orca-security"
  role_name = "orca-scanner-role"

  aws_auth_configmap_data = {
    mapRoles    = yamlencode([local.role])
    mapUsers    = yamlencode([local.user_name])
    mapAccounts = yamlencode([])
  }
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = local.aws_auth_configmap_data
}

resource "kubernetes_namespace" "this" {
  metadata {
    annotations = {
      name = local.namespace
    }

    name = local.namespace
  }
}

resource "kubernetes_cluster_role" "this" {
  metadata {
    name = local.role_name
  }

  rule {
    api_groups = [""]
    resources  = ["*.*"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_role_binding" "this" {
  metadata {
    name      = "orca-scanner-cluster-role-binding"
    namespace = local.namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.this.metadata[0].name
  }
  subject {
    kind      = "User"
    name      = local.user_name
    api_group = "rbac.authorization.k8s.io"
  }

  depends_on = [
    kubernetes_namespace.this
  ]
}