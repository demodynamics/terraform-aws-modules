output "output_data" {
  description = "OIDC Identity provider details"
  value = {
    arn = aws_iam_openid_connect_provider.oidc_identity_provider.arn
  }
}