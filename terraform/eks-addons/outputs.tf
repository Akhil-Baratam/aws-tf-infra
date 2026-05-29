output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}

output "cluster_name" {
  description = "EKS cluster Name"
  value       = local.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = data.terraform_remote_state.eks.outputs.cluster_endpoint
}

output "cluster_oidc_issuer_url" {
  description = "EKS cluster OIDC issuer URL"
  value       = data.terraform_remote_state.eks.outputs.cluster_oidc_issuer_url
}

output "cluster_oidc_provider_arn" {
  description = "EKS cluster OIDC provider ARN"
  value       = local.eks_oidc_provider_arn
}

output "cluster_certificate_authority_data" {
  value       = data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data
  sensitive   = true
  description = "cluster_certificate_authority_data"
}

output "argocd_initial_admin_secret" {
  value     = data.kubernetes_secret.argocd_initial_admin_secret.data
  sensitive = true
}