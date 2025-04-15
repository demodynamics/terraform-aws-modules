variable "repo_name" {
  description = "Public ECR repository name"
  type = string
  default = ""

  validation {
    condition     = length(var.repo_name) > 0 && can(regex("^[a-z0-9.-]{2,256}$", var.repo_name))
    error_message = "The repository name must be 2-256 characters long and can only contain lowercase letters, numbers, hyphens (-), and periods (.)."
  }
}

variable "default_tags" {
  description = "Default Tags to apply to all resources"
  type        = map(string)
  default = {
    Owner       = ""
    Environment = ""
    Project     = ""
 }

   validation {
    condition = alltrue([
      for v in values(var.default_tags) : 
        can(regex("^[a-z0-9-]*$", v)) && length(v) <= 100
    ]) && (contains([""], var.default_tags["Environment"]) || contains(["dev", "stage", "prod", "test", "qa"], var.default_tags["Environment"]))
    error_message = <<EOT
      - Tag values must be 1-100 characters long, contain only lowercase letters, numbers, and hyphens (-), and cannot contain spaces or underscores (_).
      - Environment tag can be empty or must be one of the allowed values ["dev", "stage", "prod", "test", "qa"].
      EOT
  }
}