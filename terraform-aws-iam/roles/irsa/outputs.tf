output "output_data" {
  value = {
    name            = aws_iam_role.irsa.name
    arn             = aws_iam_role.irsa.arn
    namespace       = var.service_account_namespace
    aervice_account = var.service_account_name
  }
}