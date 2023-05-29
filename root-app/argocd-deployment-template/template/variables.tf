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

variable "tags" {
  description = "Tags"
  type        = map(any)
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