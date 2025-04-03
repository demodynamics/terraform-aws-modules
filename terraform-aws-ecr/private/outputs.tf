output "output_data" {
  description = "Private ECR repository's details"
  value = {
    name                   = aws_ecr_repository.private_repo.name
    arn                    = aws_ecr_repository.private_repo.arn
    url                    = aws_ecr_repository.private_repo.repository_url
    registryID             = aws_ecr_repository.private_repo.registry_id
    imageTagMutabilityType = aws_ecr_repository.private_repo.image_tag_mutability
  }
}