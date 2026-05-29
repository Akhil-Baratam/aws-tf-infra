locals {
  environment           = terraform.workspace
  cluster_name          = "${local.environment}-${var.cluster_name}"
  eks_oidc_provider     = replace(data.terraform_remote_state.eks.outputs.cluster_oidc_issuer_url, "https://", "")
  eks_oidc_provider_arn = data.terraform_remote_state.eks.outputs.cluster_oidc_provider_arn

  # namespaces that k8s ships with — we never create these
  default_k8s_namespaces = toset(["default", "kube-node-lease", "kube-public", "kube-system"])

  # namespaces this setup always needs regardless of what the caller passes
  required_k8s_namespaces = toset(["argocd", "lb-controller"])

  non_default_k8s_namespaces = setsubtract(
    setunion(local.required_k8s_namespaces, var.k8s_namespaces),
    local.default_k8s_namespaces
  )

  # create ECR pull secrets in all app namespaces
  ecr_secret_namespaces = var.k8s_namespaces


  tags = {
    "ClusterName" = local.cluster_name
    "Environment" = local.environment
  }
}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "eks_cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}