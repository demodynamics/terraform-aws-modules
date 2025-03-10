output "public_ecr_data" {
  value = {
    "Public Repo ID"           = aws_ecrpublic_repository.public_repo[*].id
    "Public Repo Name(s)"         = aws_ecrpublic_repository.public_repo[*].repository_name
    "Public Repo Full Arn"     = aws_ecrpublic_repository.public_repo[*].arn
    "Public Repo URL"          = aws_ecrpublic_repository.public_repo[*].repository_uri
    "Public Repo Registry ID"  = aws_ecrpublic_repository.public_repo[*].registry_id
  }
}