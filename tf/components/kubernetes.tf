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
  #This step will FAIL unless port-forwarding is on, WIP
  provisioner "local-exec" {
    command = "argocd login localhost:8080 --username admin --password ${random_password.argopass.result} --insecure | argocd repo add https://github.com/${var.git_server}/${var.git_repository} --username ${var.git_username} --password ${var.git_password} --name ${var.git_repository} "
  }
  provisioner "local-exec" {
    command = "argocd login localhost:8080 --username admin --password ${random_password.argopass.result} --insecure | argocd app create ${var.application_name} --repo https://github.com/${var.git_server}/${var.git_repository} --path ${var.yaml_config_directory} --dest-server https://kubernetes.default.svc --dest-namespace ${kubernetes_namespace.default_namespace.metadata.0.name}"
  }
  provisioner "local-exec" {     
     command = "kubectl create secret docker-registry regcred --docker-server=https://index.docker.io/v1/ --docker-username=${var.dockerhub_user} --docker-password=${var.dockerhub_password} --docker-email=${var.email} -n ${kubernetes_namespace.default_namespace.metadata.0.name}"
  }
  depends_on = [
    kubernetes_namespace.project_namespace,
  ]
}