output "eks_ssh_private_key_pem" {
  description = "The private key for SSH access to EKS nodes. Save this securely!"
  value       = tls_private_key.ssh.private_key_pem
  sensitive   = true
}

output "key_name" {
  description = "The name of the AWS EC2 key pair"
  value       = aws_key_pair.ssh.key_name
}

output "private_key_pem" {
  description = "The private key in PEM format"
  value       = tls_private_key.ssh.private_key_pem
  sensitive   = true
}
