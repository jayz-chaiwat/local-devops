provider "helm" {
  version = "~> 1.2"
}

resource "helm_release" "kubernetes_dashboard_release" {
  name  = "kubernetes-dashboard"
  namespace = "kubernetes-dashboard"
  create_namespace = true
  repository = "https://kubernetes.github.io/dashboard/"
  chart = "kubernetes-dashboard"
  
  set {
    name  = "metricsScraper.enabled"
    value = true
  }

  set {
    name  = "metrics-server.enabled"
    value = true
  }
}

resource "helm_release" "argocd_release" {
  name  = "argocd"
  namespace = "argocd"
  create_namespace = true
  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-cd"

  depends_on = [
    helm_release.kubernetes_dashboard_release,
  ]
}