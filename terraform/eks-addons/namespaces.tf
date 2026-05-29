resource "kubernetes_namespace" "non_default_namespaces" {
  for_each = local.non_default_k8s_namespaces

  metadata {
    name = each.key
    labels = {
      "app.kubernetes.io/instance" = each.key
      "app.kubernetes.io/name"     = each.key
    }
  }
}
