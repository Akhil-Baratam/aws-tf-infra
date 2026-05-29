# Cluster Autoscaler via Helm
# Automatically scales node groups based on pod scheduling demand.

module "cluster_autoscaler_irsa" {
  count = var.enable_cluster_autoscaler ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "~> 6.2"
  name    = "${local.cluster_name}-cluster-autoscaler"

  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_names = [data.terraform_remote_state.eks.outputs.cluster_name]

  oidc_providers = {
    main = {
      provider_arn               = local.eks_oidc_provider_arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler"]
    }
  }
}

resource "helm_release" "cluster_autoscaler" {
  count = var.enable_cluster_autoscaler ? 1 : 0

  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = var.aws_cluster_autoscaler_chart_version

  set {
    name  = "autoDiscovery.clusterName"
    value = data.terraform_remote_state.eks.outputs.cluster_name
  }

  set {
    name  = "awsRegion"
    value = var.aws_region
  }

  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.cluster_autoscaler_irsa[0].iam_role_arn
  }

  set {
    name  = "extraArgs.stderrthreshold"
    value = "ERROR"
  }

  set {
    name  = "extraArgs.v"
    value = "0"
  }

  depends_on = [module.cluster_autoscaler_irsa]
}
