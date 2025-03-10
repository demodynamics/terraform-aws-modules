output "private_ecr_data" {
  value = {
    "Private Repo Names" = aws_ecr_repository.private_repo[*].name
    "Image Tag Mutability Type" = aws_ecr_repository.private_repo[*].image_tag_mutability
  }
}