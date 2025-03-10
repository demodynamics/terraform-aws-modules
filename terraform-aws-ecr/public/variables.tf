variable "repo_name" {
  type = list(string)
}

variable "default_tags" {
  description = "Default Tags to apply to all resources"
  type = map(string)
}
