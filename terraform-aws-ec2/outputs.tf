
output "output_data" {
  description = "Output data for the EC2 instance"
  value = {
    instance_id         = aws_instance.this.id
    instance_public_ip  = aws_instance.this.public_ip
    instance_public_dns = aws_instance.this.public_dns
  }

}
