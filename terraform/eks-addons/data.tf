# Remote state from the EKS cluster module
data "terraform_remote_state" "eks" {
  backend   = "s3"
  workspace = terraform.workspace

  config = {
    bucket = var.backend_bucket_name
    key    = "eks/terraform.tfstate"
    region = var.aws_region
  }
}
