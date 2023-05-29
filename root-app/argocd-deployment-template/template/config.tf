################################### Backend ###################################
terraform {
  backend "s3" {
    bucket = "acme-terraform-state-iac-s3"
    key    = "assesment/${aws_account_name}/${eks_cluster_name}/argocd.tfstate"
    region = "eu-central-1"
    acl    = "bucket-owner-full-control"
  }
}

data "terraform_remote_state" "acme_aws_shared_eks_data" {
  backend = "s3"
  config = {
    bucket = "acme-terraform-state-iac-s3"
    key    = "assesment/${aws_account_name}/${eks_cluster_name}/eks-cluster.tfstate"
    region = "eu-central-1"
  }
}

################################### Provider ###################################
provider "aws" {
  region = var.aws_region
  # assume_role {
  #   role_arn = var.role_arn
  # }
}

provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.acme_aws_shared_eks_data.outputs.cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.acme_aws_shared_eks_data.outputs.cluster_ca_certificate)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

provider "kubernetes" {
    host                   = data.terraform_remote_state.acme_aws_shared_eks_data.outputs.cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.acme_aws_shared_eks_data.outputs.cluster_ca_certificate)
    token                  = data.aws_eks_cluster_auth.this.token
}


data "aws_eks_cluster" "this" {
  name = data.terraform_remote_state.acme_aws_shared_eks_data.outputs.cluster_id
}

data "aws_eks_cluster_auth" "this" {
  name = data.terraform_remote_state.acme_aws_shared_eks_data.outputs.cluster_id
}
