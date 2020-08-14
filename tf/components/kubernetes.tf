provider "kubernetes" {
  version = "~> 1.12"
}

resource "kubernetes_namespace" "default_namespace" {
  metadata {
    name = var.namespaces
  }

  depends_on = [
    helm_release.argocd_release,
  ]
}

resource "null_resource" "secret" {
  provisioner "local-exec" {     
     command = "kubectl create secret docker-registry regcred --docker-server=https://index.docker.io/v1/ --docker-username=${var.dockerhub_user} --docker-password=${var.dockerhub_password} --docker-email=${var.email} -n ${kubernetes_namespace.default_namespace.metadata.0.name}"
  }
}