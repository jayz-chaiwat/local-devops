provider "helm" {
  version = "~> 1.2"
}

provider "random" {
  version = "~> 2.3"
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

resource "random_password" "argopass" {
  length = 16
  special = true
  override_special = "_%@"

  depends_on = [
    helm_release.kubernetes_dashboard_release,
  ]
}

resource "helm_release" "argocd_release" {
  name  = "argocd"
  namespace = "argocd"
  create_namespace = true
  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-cd"

  set {
    name = "configs.secret.argocdServerAdminPassword"
    value = bcrypt(random_password.argopass.result)
  }

  set {
    name = "configs.secret.argocdServerAdminPasswordMtime"
    value = "date \"2030-01-01T23:59:59Z\" now"
  }

  depends_on = [
    random_password.argopass.result,
  ]
}