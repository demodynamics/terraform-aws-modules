output "output_data" {
  description = "Private ECR repository's details"
  value       = {
    name                      = aws_ecr_repository.private.name
    arn                       = aws_ecr_repository.private.arn
    url                       = aws_ecr_repository.private.repository_url
    registry_id               = aws_ecr_repository.private.registry_id
    image_tag_mutability_type = aws_ecr_repository.private.image_tag_mutability
  }
}