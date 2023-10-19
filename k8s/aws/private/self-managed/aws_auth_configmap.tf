################################################################################
#                               aws-auth configmap                             #
################################################################################

resource "kubernetes_secret_v1" "this" {
  metadata {
    name = "${kubernetes_service_account.this.metadata[0].name}-service-account-token"
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.this.metadata[0].name
    }
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  type = "kubernetes.io/service-account-token"
}

resource "kubernetes_service_account" "this" {
  metadata {
    name      = local.service_account_name
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  secret {
    name = "${local.service_account_name}-service-account-token"
  }
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
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.this.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.this.metadata[0].name
    namespace = kubernetes_namespace.this.metadata[0].name
  }
}