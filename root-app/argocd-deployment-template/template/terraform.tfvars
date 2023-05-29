# ################################### General ###################################
aws_region            = "${aws_region}"
role_arn              = "${role_arn}"
aws_account_name      = "${aws_account_name}"
environment           = "${environment}"
aws_auth_accounts     = "${aws_auth_accounts}"


# ############################################# Tags ###########################################
tags = ${tags}

vpc_name                      = "${vpc_name}"
eks_cluster_name              = "${eks_cluster_name}"
argocd_server_host_url        = "${argocd_server_host_url}"
hosted_zone                   = "${hosted_zone}"
argocd_repo_url               = "${argocd_repo_url}"
argocd_global_image_repo      = "${argocd_global_image_repo}"
argocd_global_image_tag       = "${argocd_global_image_tag}"
argocd_redis_image_repo       = "${argocd_redis_image_repo}"
argocd_redis_image_tag        = "${argocd_redis_image_tag}"        
argocd_dex_image_repo         = "${argocd_dex_image_repo}"
argocd_dex_image_tag          = "${argocd_dex_image_tag}"
prefix_cluster                = "${prefix_cluster}"