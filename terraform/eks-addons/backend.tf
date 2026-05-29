terraform {
  backend "s3" {
    bucket         = "apex-app-tf-state"
    key            = "eks-addons/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "apex-app-tf-lock"
    encrypt        = true
  }
}
