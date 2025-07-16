output "ssh_key_name" {
  description = "The name of the AWS EC2 key pair"
  value       = aws_key_pair.ssh.key_name
}

output "ssh_private_key_pem" {
  description = "The private key in PEM format for SSH access to EC2 Instances. Save this securely!"
  value       = tls_private_key.ssh.private_key_pem
  sensitive   = true
}

output "ssh_public_key_openssh" {
  value     = tls_private_key.ssh.public_key_openssh
  sensitive = false
}
