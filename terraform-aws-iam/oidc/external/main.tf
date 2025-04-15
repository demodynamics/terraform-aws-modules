# Creating OIDC Identity Provider for external systems (e.g., GitHub Actions, Google, Okta, Auth0)
resource "aws_iam_openid_connect_provider" "oidc_identity_provider" {
  url             = var.issuer_url 
  client_id_list  = var.client_id_list                       
  thumbprint_list = var.thumbprint_list
  tags            = {
    name = "${var.issuer_service_name} OIDC Identity Provider"
  }
}