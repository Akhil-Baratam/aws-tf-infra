# Metrics Server
# Required for Horizontal Pod Autoscaler (HPA) to work.
# HPA reads CPU/memory metrics from this to decide pod scaling.

resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "3.12.1"

  set {
    name  = "apiService.create"
    value = "true"
  }
}
