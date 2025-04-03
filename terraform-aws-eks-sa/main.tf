# Create Kubernetes Service Account: A Service Account provides an identity for processes that run in a Pod.
resource "kubernetes_service_account" "service_account" {
  metadata {
    name        = var.service_account_name # Service Account name
    namespace   = var.service_account_namespace # Namespace in cluster wher will be Service Account Created
    annotations = {
      "eks.amazonaws.com/role-arn" = var.irsa_arn # IRSA Arn that gives service account permissions defined in policy(s) attached to IRSA
    }
  }
}

