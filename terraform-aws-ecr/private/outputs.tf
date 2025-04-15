output "output_data" {
  description = "Private ECR repository's details"
  value = {
    name                   = aws_ecr_repository.private.name
    arn                    = aws_ecr_repository.private.arn
    url                    = aws_ecr_repository.private.repository_url
    registryID             = aws_ecr_repository.private.registry_id
    imageTagMutabilityType = aws_ecr_repository.private.image_tag_mutability
  }
}