output "private_ecr_data" {
  value = {
    "Private Repo Name(s)"      = aws_ecr_repository.private_repo[*].name
    "Image Tag Mutability Type" = aws_ecr_repository.private_repo[*].image_tag_mutability
    "Private Repo Full Arn"     = aws_ecr_repository.private_repo[*].arn
    "Private Repo URL"          = aws_ecr_repository.private_repo[*].repository_url
    "Private Repo Registry ID"  = aws_ecr_repository.private_repo[*].registry_id
    
  }
}