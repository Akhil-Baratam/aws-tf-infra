locals {
  environment           = terraform.workspace
  cluster_name          = "${local.environment}-${var.cluster_name}"
  eks_oidc_provider     = replace(data.terraform_remote_state.eks.outputs.cluster_oidc_issuer_url, "https://", "")
  eks_oidc_provider_arn = data.terraform_remote_state.eks.outputs.cluster_oidc_provider_arn


}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "eks_cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}