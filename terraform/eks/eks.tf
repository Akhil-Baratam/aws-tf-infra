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

  # Essential addons — without these, nodes cannot become Ready
  addons = {
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
  }

  eks_managed_node_groups = {
    apex-dev-01 = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      capacity_type  = "ON_DEMAND"
      instance_types = var.node_instance_types
      ami_type       = "AL2023_x86_64_STANDARD"

      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size
    }
  }

  tags = local.tags
}
