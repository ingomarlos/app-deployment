# ################################### General ###################################

variable "aws_auth_accounts" {
  description = "aws_auth_accounts"
  type        = string
}

variable "aws_region" {
  description = "aws region"
  type        = string
}

variable "aws_account_name" {
  description = "AWS account name"
  type        = string
}

variable "vpc_name" {
  description = "vpc name"
  type        = string
}

variable "role_arn" {
  description = "Role arn to deploy the resources"
  type        = string
}

variable "environment" {
  description = "Environment for TAG"
  type        = string
}


variable "argocd_server_host_url" {
  description = "argocd_server_host_url"
  type        = string
}

variable "eks_cluster_name" {
  description = "eks_cluster_name"
  type        = string
}

# The tags is set as string as this is only to render the tf files using the templates, the rendered version should be set as map
variable "tags" {
  description = "Tags"
  type        = string
}

variable "hosted_zone" {
  description = "hosted_zone"
  type        = string
}

variable "argocd_repo_url" {
  description = "argocd_repo_url"
  type        = string
}

variable "argocd_global_image_repo" {
  description = "argocd_global_image_repo"
  type        = string
}

variable "argocd_global_image_tag" {
  description = "argocd_global_image_tag"
  type        = string
  default     = ""
}

variable "argocd_redis_image_repo" {
  description = "argocd_redis_image_repo"
  type        = string
}

variable "argocd_redis_image_tag" {
  description = "argocd_redis_image_tag"
  type        = string
  default     = ""
}

variable "argocd_dex_image_repo" {
  description = "argocd_dex_image_repo"
  type        = string
}

variable "argocd_dex_image_tag" {
  description = "argocd_dex_image_tag"
  type        = string
  default     = ""
}

variable "prefix_cluster" {
  description = "prefix_cluster in the path"
  type        = string
}

variable "proxy_config" {
  description = "proxy configuration for PCI env"
  type        = string
  default     = ""
}

variable "notification_config" {
  description = "argocd notifications configuration"
  type        = string
  default     = ""
}

variable "dex_config" {
  description = "argocd dex configuration"
  type        = string
  default     = ""
}