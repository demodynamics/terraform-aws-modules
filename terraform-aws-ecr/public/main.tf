terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Creating Public ECR Repository. This resource can only be used in the us-east-1 region.
resource "aws_ecrpublic_repository" "public_repo" {
  count = length(var.repo_name)
  repository_name = "${var.default_tags["Project"]}-${var.repo_name[count.index]}" # var.default_tags["Project"]` Taking value of key (Project) from map (var.default_tags map)
  
  tags = var.default_tags
}