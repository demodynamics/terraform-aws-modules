
# 1. Define the secret container in AWS Secrets Manager
resource "aws_secretsmanager_secret" "secret" {
  # You can customize the name of your secret
  name                    = var.secret_name
  description             = " Creating Secrets Manager secret"
  recovery_window_in_days = 7 # Recommended practice

  tags = merge(var.tags, {
    Name = "${var.secret_name}"
  })
}

# 2. Store the secret value in the secret container
resource "aws_secretsmanager_secret_version" "secret_version" {
  # Reference the secret container created above
  secret_id = aws_secretsmanager_secret.secret.id
  # Secret value (e.g., EC2 SSH private key) to store in Secrets Manager container
  secret_string = var.secret_value
}
