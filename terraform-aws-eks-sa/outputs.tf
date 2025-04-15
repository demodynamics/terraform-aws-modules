output "output_data" {
  description = "ServiceAccount Details"
  value = {
    "Service Account Data"  = kubernetes_service_account.service_account.metadata
  }
}