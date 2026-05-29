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
