output "launch_template_id" {
  description = "The ID of the launch template"
  value       = aws_launch_template.this.id
}

output "launch_template_version" {
  description = "The latest version of the launch template"
  value       = aws_launch_template.this.latest_version
}
