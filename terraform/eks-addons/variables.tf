variable "aws_region" {
  type        = string
  default     = "ap-south-1"
  description = "AWS region"
}

variable "backend_bucket_name" {
  type        = string
  description = "S3 bucket name that holds the EKS remote state"
}

variable "cluster_name" {
  description = "Main cluster_name for this state (used in resource names, etc...)"
  type        = string

  validation {
    condition     = length(var.cluster_name) <= 18 && length(regexall("^[[:alpha:]]+(?:[[:alnum:]]|-){3,}[[:alnum:]]$", var.cluster_name)) > 0
    error_message = "The 'label' must be at least 5 characters long, no more than 18 characters, start with a letter, end with a letter or number, and only contain letters, numbers, and hyphens"
  }
}

variable "k8s_namespaces" {
  description = "The initial namespaces to create in the EKS cluster"
  type        = set(string)
}



# ─── ArgoCD ──────────────────────────────────────────────────────────────────
variable "enable_argo" {
  type        = bool
  default     = false
  description = "enable_argo"
}

variable "argocd_version" {
  type        = string
  description = "argocd version"
}

variable "argo_root_app_repo_url" {
  type        = string
  default     = "default"
  description = "argo_root_app_repo_url"
}

variable "argo_root_app_repo_revision" {
  type        = string
  default     = "main"
  description = "argo_root_app_repo_revision"
}

variable "argo_apps_directory" {
  type        = string
  default     = ""
  description = "argo_apps_directory"
}

variable "argo_repo_ssh_private_key" {
  type        = string
  default     = ""
  sensitive   = true
  description = "SSH private key for ArgoCD to access the Git repository"
}

# ─── AWS Load Balancer Controller ────────────────────────────────────────────

variable "enable_lb_controller" {
  type        = bool
  default     = false
  description = "Create the AWS Load balancer controller in the cluster"
}

variable "aws_lb_controller_chart_version" {
  type        = string
  default     = ""
  description = "aws_lb_controller_chart_version"
}

variable "aws_load_balancer_controller_namespace" {
  type        = string
  default     = "lb-controller"
  description = "Namespace for the AWS LB controller"
}

# ─── Cluster Autoscaler ─────────────────────────────────────────────────────

variable "enable_cluster_autoscaler" {
  type        = bool
  default     = false
  description = "enable_cluster_autoscaler"
}

variable "aws_cluster_autoscaler_chart_version" {
  description = "helm chart version for cluster autoscaler"
  type        = string
  default     = "9.29.0"
}
