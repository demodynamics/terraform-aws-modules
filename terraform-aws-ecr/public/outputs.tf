output "output_data" {
  description = "Public ECR Repository's Details"
  value = {
    name        = aws_ecrpublic_repository.public_repo.repository_name
    id          = aws_ecrpublic_repository.public_repo.id
    arn         = aws_ecrpublic_repository.public_repo.arn
    url         = aws_ecrpublic_repository.public_repo.repository_uri
    registryID  = aws_ecrpublic_repository.public_repo.registry_id
  }
}