output "public_ecr_data" {
  value = {
    "Public Repo name" = aws_ecrpublic_repository.public_repo.repository_name
  }
}