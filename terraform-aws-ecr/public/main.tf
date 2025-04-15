# Creating Public ECR Repository. This resource can only be used in the us-east-1 region.
resource "aws_ecrpublic_repository" "public" {
  repository_name = join("-", compact([var.default_tags["Project"], var.repo_name, "public-repository" ]) )
  tags            = var.default_tags
}