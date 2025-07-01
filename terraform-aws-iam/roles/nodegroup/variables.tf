variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
  default     = "main"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,64}$", var.cluster_name))
    error_message = "cluster_name must be between 1 and 64 characters, and can only contain lowercase letters, numbers, and hyphens."
  }
}

variable "nodegroup_name" {
  description = "EKS Node Group Name"
  type        = string
  default     = "main"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,64}$", var.nodegroup_name))
    error_message = "node_group_name must be between 1 and 64 characters, and can only contain lowercase letters, numbers, and hyphens."
  }

}

variable "policies" {
  description = "List of AWS managed permissions policy(s) for Node Group Role"
  type        = set(string)
  default     = ["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy", "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy", "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"]

  validation {
    condition     = alltrue([for p in var.policies : can(regex("^arn:aws:iam::aws:policy/[A-Za-z0-9+=,.@_-]+$", p))])
    error_message = "Each policy must be a valid AWS managed policy ARN in the format 'arn:aws:iam::aws:policy/<PolicyName>'."
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
