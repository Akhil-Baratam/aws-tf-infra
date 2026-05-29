data "aws_ecr_authorization_token" "token" {}

resource "kubernetes_secret" "ecr_secret" {
  for_each = local.ecr_secret_namespaces

  metadata {
    name      = "ecr-secret"
    namespace = each.key
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${data.aws_ecr_authorization_token.token.proxy_endpoint}" = {
          auth = data.aws_ecr_authorization_token.token.authorization_token
        }
      }
    })
  }

  depends_on = [kubernetes_namespace.non_default_namespaces]
}
