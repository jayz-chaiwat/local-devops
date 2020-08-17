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
    command = "kubectl expose deployment argocd-server -n argocd --type=NodePort --name argocd-server-exposed"
  }
  provisioner "local-exec" {
    command = "kubectl patch svc argocd-server-exposed -n argocd --type=json -p '[{\"op\": \"replace\", \"path\": \"/spec/type\", \"value\": \"NodePort\"}, {\"op\": \"replace\", \"path\": \"/spec/ports/0/nodePort\", \"value\" : 30080}]'"
    interpreter = ["PowerShell", "-Command"]
  }
  # This step will FAIL unless port-forwarding is on, WIP
  provisioner "local-exec" {
    command = "argocd login ${minikube_ip}:30080 --username admin --password ${random_password.argopass.result} --insecure | argocd repo add https://github.com/${var.git_server}/${var.git_repository} --username ${var.git_username} --password ${var.git_password} --name ${var.git_repository} "
    interpreter = ["PowerShell", "-Command"]
  }
  provisioner "local-exec" {
    command = "argocd login ${minikube_ip}:30080 --username admin --password ${random_password.argopass.result} --insecure | argocd app create ${var.application_name} --repo https://github.com/${var.git_server}/${var.git_repository} --path ${var.yaml_config_directory} --dest-server https://kubernetes.default.svc --dest-namespace ${kubernetes_namespace.default_namespace.metadata.0.name}"
    interpreter = ["PowerShell", "-Command"]
  }
  provisioner "local-exec" {     
    command = "kubectl create secret docker-registry regcred --docker-server=https://index.docker.io/v1/ --docker-username=${var.dockerhub_user} --docker-password=${var.dockerhub_password} --docker-email=${var.email} -n ${kubernetes_namespace.default_namespace.metadata.0.name}"
    interpreter = ["PowerShell", "-Command"]
  }
  provisioner "local-exec" {
    command = "kubectl delete svc argocd-server-exposed -n argocd"
  }
  depends_on = [
    kubernetes_namespace.default_namespace,
  ]
}