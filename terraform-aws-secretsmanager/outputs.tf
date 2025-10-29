output "secret_arn" {
  description = "The ARN of the AWS Secrets Manager secret containing the private key."
  value       = aws_secretsmanager_secret.secret.arn
}

output "secret_name" {
  description = "The Name of the AWS Secrets Manager secret."
  value       = aws_secretsmanager_secret.secret.name
}

output "secret_version_id" {
  description = "The Version ID of the AWS Secrets Manager secret."
  value       = aws_secretsmanager_secret_version.secret_version.version_id

}
