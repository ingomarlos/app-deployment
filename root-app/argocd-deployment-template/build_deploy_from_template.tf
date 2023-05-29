resource "local_file" "config-tf" {
  content = templatefile("${path.module}/template/config.tf",
    {
      eks_cluster_name              = var.eks_cluster_name
      aws_account_name              = var.aws_account_name
    }
  )
  filename = "deploy/config.tf"
}

resource "local_file" "data-tf" {
  content = templatefile("${path.module}/template/data.tf",
    {
      aws_account_name = var.aws_account_name
    })
  filename = "deploy/data.tf"
}


resource "local_file" "helm-argocd-tf" {
  content = templatefile("${path.module}/template/helm-argocd.tf",
    {
      aws_account_name = var.aws_account_name
    }
  )
  filename = "deploy/helm-argocd.tf"
}


resource "local_file" "terraform-tfvars" {
  content = templatefile("${path.module}/template/terraform.tfvars",
    {
      eks_cluster_name              = var.eks_cluster_name
      aws_region                    = var.aws_region
      role_arn                      = var.role_arn
      aws_account_name              = var.aws_account_name
      tags                          = var.tags
      aws_auth_accounts             = var.aws_auth_accounts
      vpc_name                      = var.vpc_name
      environment                   = var.environment
      argocd_server_host_url        = var.argocd_server_host_url
      hosted_zone                   = var.hosted_zone
      argocd_repo_url               = var.argocd_repo_url
      argocd_global_image_repo      = var.argocd_global_image_repo
      argocd_global_image_tag       = var.argocd_global_image_tag
      argocd_redis_image_repo       = var.argocd_redis_image_repo
      argocd_redis_image_tag        = var.argocd_redis_image_tag
      argocd_dex_image_repo         = var.argocd_dex_image_repo
      argocd_dex_image_tag          = var.argocd_dex_image_tag
      prefix_cluster                = var.prefix_cluster
    }
  )
  filename = "deploy/terraform.tfvars"
}


resource "local_file" "variables-tf" {
  content = templatefile("${path.module}/template/variables.tf",
    {
      aws_account_name              = var.aws_account_name
    }
  )
  filename = "deploy/variables.tf"
}


resource "local_file" "argocd-values-yaml" {
  content = templatefile("${path.module}/template/values/argocd-values.yaml",
    {
      aws_account_name              = var.aws_account_name
      proxy_config                  = var.proxy_config
      notification_config           = var.notification_config
      dex_config                    = var.dex_config
    }
  )
  filename = "deploy/values/argocd-values.yaml"
}

resource "local_file" "argocd-root-app-values-yaml" {
  content = templatefile("${path.module}/template/values/argocd-root-app-values.yaml",
    {
      aws_account_name              = var.aws_account_name
    }
  )
  filename = "deploy/values/argocd-root-app-values.yaml"
}
