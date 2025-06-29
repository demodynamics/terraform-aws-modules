variable "cluster_version" {
  description = "EKS Cluster Version"
  type        = string
  default     = "1.33"

  validation {
    condition     = can(regex("^[0-9]{1,2}.[0-9]{1,2}$", var.cluster_version)) && length(var.cluster_version) <= 5
    error_message = "The EKS cluster version must be in the format X.Y (e.g., 1.27) and cannot exceed 5 characters."
  }

}

variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
  default     = "main"

  validation {
    condition     = can(regex("^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$", var.cluster_name)) && length(var.cluster_name) <= 100
    error_message = "The EKS cluster name must be 1-100 characters long, contain only letters, numbers, and hyphens, and cannot start or end with a hyphen."
  }

  /*
  AWS EKS Cluster Name Rules

✅ Allowed Characters:
    Lowercase & uppercase letters (a-z, A-Z)
    Numbers (0-9)
    Hyphens (-) (but cannot start or end with a hyphen)

❌ Not Allowed:
    Underscores (_)
    Spaces
    Special characters (@, !, #, $, etc.)

 AWS EKS Node Group Name Rules
✅ Allowed Characters:
      Letters (a-z, A-Z)
      Numbers (0-9)
      Hyphens (-) (cannot start or end with a hyphen)

❌ Not Allowed:
      Underscores (_)
      Spaces
      Special characters (@, !, #, $, etc.)
      More than 63 characters
*/
}

variable "cluster_role_arn" {
  description = "ARN of the EKS Cluster role"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "Subnet ID's of VPC Where the cluster will be created"
  type        = list(string)
  default     = [""]
}

variable "security_group_ids" {
  description = "Security Group ID's to attach to the EKS Cluster"
  type        = list(string)
  default     = [""]
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
