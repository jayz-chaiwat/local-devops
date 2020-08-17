variable "dockerhub_user" {
  description = "Docker user"
}

variable "dockerhub_password" {
  description = "Docker password"
}

variable "email" {
  default = "contact@appman.co.th"
  description = "Docker email"
}

variable "namespaces" {
  description = "base namespaces"
}

variable "minikube_ip" {
  description = "The endpoint of your cluster"
}

variable "git_server" {
  type=string
  description = "Git account the repository is located in"
}

variable "git_repository" {
  type=string
  description = "Git repository name (only the repo name)"
}

variable "git_username" {
  type=string
  description = "Git username to authenticate on the repository"
}

variable "git_password" {
  type=string
  description = "Git password to authenticate on the repository"
}

variable "application_name" {
  description = "Name of the application in ArgoCD deployment"
  default = "application"
  type = string
}

variable "yaml_config_directory" {
  description = "Directory containing the kubernetes or helm files"
  default = "chart"
  type = string
}