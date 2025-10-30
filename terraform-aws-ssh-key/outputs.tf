output "ssh_key_pair_name" {
  description = "The name of the AWS EC2 key pair"
  value       = aws_key_pair.ssh.key_name
}

output "ssh_private_key" {
  description = "The private key in PEM format for SSH access to EC2 Instances. Save this securely!"
  value = one(concat(
    tls_private_key.rsa_ssh[*].private_key_pem,
    tls_private_key.ed25519_ssh[*].private_key_openssh,
    tls_private_key.ecdsa_ssh[*].private_key_openssh,
  ))
  sensitive = true
}

output "ssh_public_key_openssh" {
  description = "The public key in OpenSSH format."
  value = one(concat(
    tls_private_key.rsa_ssh[*].public_key_openssh,
    tls_private_key.ed25519_ssh[*].public_key_openssh,
    tls_private_key.ecdsa_ssh[*].public_key_openssh,
  ))
  sensitive = false
}


# output "ssh_key_pair_name" {
#   description = "The name of the AWS EC2 key pair"
#   value       = aws_key_pair.ssh.key_name
# }

# output "ssh_private_key_pem" {
#   description = "The private key in PEM format for SSH access to EC2 Instances. Save this securely!"
#   value       = tls_private_key.ssh.private_key_pem
#   sensitive   = true
# }

# output "ssh_public_key_openssh" {
#   value     = tls_private_key.ssh.public_key_openssh
#   sensitive = false
# }
