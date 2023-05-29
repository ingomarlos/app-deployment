
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {

  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  version    = "5.5.16"

  values = [
    templatefile(
      "values/argocd-values.yaml",
      {
        "argocd_server_host" = "$${var.argocd_server_host_url}",
        "argocd_global_image_repo" = var.argocd_global_image_repo
        "argocd_global_image_tag"  = var.argocd_global_image_tag
        "argocd_redis_image_repo"  = var.argocd_redis_image_repo
        "argocd_redis_image_tag"   = var.argocd_redis_image_tag
        "argocd_dex_image_repo"    = var.argocd_dex_image_repo
        "argocd_dex_image_tag"     = var.argocd_dex_image_tag
      }
    )
  ]
}

resource "helm_release" "argocd-root-app" {
  depends_on = [helm_release.argocd]
  name       = "argocd-root-app"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  namespace  = "argocd"
  version    = "0.0.1"

  values = [
    templatefile(
      "values/argocd-root-app-values.yaml",
      {
        "argocd_repo_url"  = "$${var.argocd_repo_url}",
        "eks_cluster_name" = "$${var.eks_cluster_name}"
        "prefix_cluster"   = var.prefix_cluster
      }
    )
  ]
}
 
