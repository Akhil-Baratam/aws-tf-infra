# Dev environment values for eks-addons
# Usage: terraform apply -var-file=tfvars/dev.tfvars

aws_region          = "ap-south-1"
backend_bucket_name = "apex-app-tf-state"
cluster_name        = "apex-dev"

k8s_namespaces = ["dev", "ops"]

# ─── ArgoCD ──────────────────────────────────────────────────────────────────
enable_argo                 = true
argocd_version              = "9.4.15"
argo_apps_directory         = "argo-apps"
argo_root_app_repo_url      = "git@github.com:tenex-ai/app.git"
argo_root_app_repo_revision = "master"

# ─── AWS Load Balancer Controller ────────────────────────────────────────────
enable_lb_controller            = true
aws_lb_controller_chart_version = "1.13.4"

# ─── Cluster Autoscaler ─────────────────────────────────────────────────────
enable_cluster_autoscaler            = true
aws_cluster_autoscaler_chart_version = "9.43.0"
