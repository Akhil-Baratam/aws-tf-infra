module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = local.name
  kubernetes_version = var.kubernetes_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Allow the Terraform IAM principal (and any cluster creator) full
  # cluster-admin access via EKS Access Entries (replaces aws-auth configmap).
  enable_cluster_creator_admin_permissions = true

  # Expose the API server publicly so kubectl works from your local machine.
  # Private-only endpoint would require a VPN/bastion to reach the cluster.
  endpoint_public_access = true



  tags = local.tags
}
