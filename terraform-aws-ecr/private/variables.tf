variable "repo_name" {
  type = list(string)
}

variable "image_tag_mutability_type" {
  description = "MUTABLE (default) can overwrite an existing tag with a new image, IMMUTABLE cannot overwrite an existing tag "
  type = list(string)
}

variable "default_tags" {
  description = "Default Tags to apply to all resources"
  type = map(string)
}