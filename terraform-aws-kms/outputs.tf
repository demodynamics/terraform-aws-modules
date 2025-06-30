output "kms_key_id" {
  description = "The ID of the KMS key used for EKS secrets encryption"
  value       = aws_kms_key.eks.id
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used for EKS secrets encryption"
  value       = aws_kms_key.eks.arn
}
