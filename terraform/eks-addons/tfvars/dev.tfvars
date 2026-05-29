# Dev environment values for eks-addons
# Usage: terraform apply -var-file=tfvars/dev.tfvars

aws_region          = "ap-south-1"
backend_bucket_name = "apex-app-tf-state"
cluster_name        = "apex-dev"

k8s_namespaces = ["dev", "ops"]


