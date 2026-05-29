# IAM Role for ALB Controller Service Account
module "aws_lb_controller_service_account_role" {
  count = var.enable_lb_controller ? 1 : 0

  source          = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  name            = "${local.cluster_name}-lb-controller"
  use_name_prefix = true
  version         = "~> 6.2"

  oidc_providers = {
    main = {
      provider_arn               = local.eks_oidc_provider_arn
      namespace_service_accounts = ["${var.aws_load_balancer_controller_namespace}:aws-load-balancer-controller"]
    }
  }

  attach_load_balancer_controller_policy = true

  tags = {
    "managed_by" = "Terraform"
  }
}

resource "kubernetes_service_account" "aws_load_balancer_controller" {
  count      = var.enable_lb_controller ? 1 : 0
  depends_on = [kubernetes_namespace.non_default_namespaces]

  automount_service_account_token = true
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = var.aws_load_balancer_controller_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.aws_lb_controller_service_account_role[0].iam_role_arn
    }
    labels = {
      "app.kubernetes.io/name"     = "aws-load-balancer-controller"
      "app.kubernetes.io/instance" = "aws-load-balancer-controller"
    }
  }
}

# Helm release configuration
resource "helm_release" "aws_load_balancer_controller" {
  count = var.enable_lb_controller ? 1 : 0

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = var.aws_load_balancer_controller_namespace
  version    = var.aws_lb_controller_chart_version

  values = [
    "${file("charts/aws-load-balancer-controller/${var.aws_lb_controller_chart_version}/${local.cluster_name}-values.yaml")}"
  ]

  set {
    name  = "vpcId"
    value = data.terraform_remote_state.eks.outputs.vpc_id
  }

  depends_on = [
    kubernetes_namespace.non_default_namespaces,
    kubernetes_service_account.aws_load_balancer_controller,
    module.aws_lb_controller_service_account_role
  ]
}