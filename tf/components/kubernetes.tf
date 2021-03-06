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

# resource "kubernetes_secret" "docker_pull_secret" {
#   metadata {
#     name = "docker-registry"
#     namespace = kubernetes_namespace.default_namespace.metadata.0.name
#   }

#   data = {
#     ".dockerconfigjson" = "${file("../env/docker-registry.json")}"
#   }

#   type = "kubernetes.io/dockerconfigjson"
# }

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
    command = "argocd login ${var.minikube_ip}:30080 --username admin --password ${random_password.argopass.result} --insecure | argocd repo add https://github.com/${var.git_server}/${var.git_repository} --username ${var.git_username} --password ${var.git_password} --name ${var.git_repository} "
    interpreter = ["PowerShell", "-Command"]
  }
  provisioner "local-exec" {
    command = "argocd login ${var.minikube_ip}:30080 --username admin --password ${random_password.argopass.result} --insecure | argocd app create ${var.application_name} --repo https://github.com/${var.git_server}/${var.git_repository} --path ${var.yaml_config_directory} --dest-server https://kubernetes.default.svc --dest-namespace ${kubernetes_namespace.default_namespace.metadata.0.name}"
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

resource "random_password" "postgrespass" {
  length = 10
  special = true
  override_special = "_%@"

  depends_on = [
//    kubernetes_secret.docker_pull_secret,
      null_resource.secret,
  ]
}

resource "kubernetes_service" "postgres_svc" {
  metadata {
    namespace = kubernetes_namespace.default_namespace.metadata.0.name
    name = "postgres-svc"
  }
  spec {
    selector = {
       app = kubernetes_deployment.postgres.metadata.0.labels.app
    }

    port {
      port = 5432
      target_port = 5432
      node_port = 30432
    }

    type = "NodePort"
  }
}

resource "kubernetes_deployment" "postgres" {
  metadata {
    name = "postgres-db"
    namespace = kubernetes_namespace.default_namespace.metadata.0.name
    labels = {
      app = "database"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "database"
      }
    }

    template {
      metadata {
        namespace = kubernetes_namespace.default_namespace.metadata.0.name
        labels = {
          app = "database"
        }
      }

      spec {
        image_pull_secrets {
          # name = kubernetes_secret.docker_pull_secret.metadata.0.name
          name = "docker-registry"
        }
        container {
          image = "postgres:13-alpine"
          name  = "postgres"

          port {
            container_port = 5432
          }

          env {
            name = "POSTGRES_PASSWORD"
            value = random_password.postgrespass.result
          }

          readiness_probe {
            exec {
              command = ["psql", "-W",random_password.postgrespass.result, "-U", "postgres", "-d", "postgres", "-c", "SELECT 1"]
            }

            initial_delay_seconds = 15
            period_seconds        = 3
          }
          
          liveness_probe {
            exec {
              command = ["psql", "-W",random_password.postgrespass.result, "-U", "postgres", "-d", "postgres", "-c", "SELECT 1"]
            }

            initial_delay_seconds = 45
            period_seconds        = 3
          }
        }
      }
    }
  }
}
