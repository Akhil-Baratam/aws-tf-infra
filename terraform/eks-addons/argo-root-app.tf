resource "kubectl_manifest" "argocd_root_application" {
  count     = var.enable_argo ? 1 : 0
  yaml_body = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  namespace: argocd
  name: ${local.cluster_name}-root-app
  labels:
    app.kubernetes.io/name: ${local.cluster_name}-root-app
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  destination:
    namespace: argocd
    server: https://kubernetes.default.svc
  project: default
  source:
    path: "${var.argo_apps_directory}/${local.cluster_name}"
    directory:
      recurse: true
    repoURL: ${var.argo_root_app_repo_url}
    targetRevision: ${var.argo_root_app_repo_revision}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
YAML

  depends_on = [
    helm_release.argocd,
  ]
}