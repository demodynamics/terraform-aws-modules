output "secret_arn" {
  description = "The ARN of the AWS Secrets Manager secret containing the private key."
  value       = aws_secretsmanager_secret.secret.arn
}

output "secret_name" {
  description = "The Name of the AWS Secrets Manager secret."
  value       = aws_secretsmanager_secret.secret.name
}
