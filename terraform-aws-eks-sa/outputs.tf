output "service_account_data" {
  description = "Otputs Service Account Data Name, Namespace and Arn of IRSA"
  value = {
    "Service Account Data"  = kubernetes_service_account.service_account.metadata
  }
}

# output "ecr_pull_service_account_name" {
#   description = "Private ECR Access Service Account Data"
#   value = kubernetes_service_account.ecr_pull_sa.metadata
# }