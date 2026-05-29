# Helm release configuration
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  version    = var.argocd_version

  values = [
    "${file("charts/argocd/${var.argocd_version}/${local.cluster_name}-values.yaml")}"
  ]

  depends_on = [
    kubernetes_namespace.non_default_namespaces
  ]
}

data "kubernetes_secret" "argocd_initial_admin_secret" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = helm_release.argocd.namespace
  }

  depends_on = [
    helm_release.argocd,
  ]
}

# ArgoCD GitHub Repository Connection (SSH)
resource "kubernetes_secret" "argocd_repo" {
  count = var.enable_argo ? 1 : 0

  metadata {
    name      = "repo-${local.cluster_name}"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  type = "Opaque"

  data = {
    type          = "git"
    url           = var.argo_root_app_repo_url
    sshPrivateKey = var.argo_repo_ssh_private_key
  }

  depends_on = [
    helm_release.argocd,
  ]
}