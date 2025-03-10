# Create Kubernetes Service Account: A Service Account provides an identity for processes that run in a Pod.
resource "kubernetes_service_account" "service_account" {
  metadata {
    name      = "${var.default_tags["Project"]}-${var.service_account_name}" # Service Account name
    namespace = var.service_account_namespace # Namespace in cluster wher will be Service Account Created
    annotations = {
      "eks.amazonaws.com/role-arn" = var.irsa_arn # IRSA Arn that gives ervice account permissions defined in policy(s) attache to IRSA
    }
  }
}

