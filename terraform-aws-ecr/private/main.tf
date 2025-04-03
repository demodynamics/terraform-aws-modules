# Creating Private ECR Repository
resource "aws_ecr_repository" "private" {
  name                 = join("-", compact([var.default_tags["Project"], var.repo_name, "private-repository" ]) )
  image_tag_mutability = var.image_tag_mutability_type
  tags                 = var.default_tags
}