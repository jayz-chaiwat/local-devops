output "argocd_initial_password" {
  value = random_password.argopass.result
  sensitive = true  
  depends_on = [
    random_password.argopass,
  ]
}

output "postgres_password" {
  value = random_password.postgrespass.result

  depends_on = [
    random_password.postgrespass.result,
  ]
}