output "argocd_initial_password" {
  value = random_password.argopass.result
  sensitive = true  
  depends_on = [
    random_password.argopass.result,
  ]
}