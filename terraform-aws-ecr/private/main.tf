terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Creating Private ECR Repository
resource "aws_ecr_repository" "private_repo" {
  count                = length(var.repo_name)
  name                 = "${var.default_tags["Project"]}-${var.repo_name[count.index]}" 
  image_tag_mutability = var.image_tag_mutability_type[count.index]

  tags = var.default_tags
}