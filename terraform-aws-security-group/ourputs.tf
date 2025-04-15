output "output_data" {
  value = {
    id   = aws_security_group.this.id
    arn  = aws_security_group.this.arn
    name = aws_security_group.this.name
  }
}