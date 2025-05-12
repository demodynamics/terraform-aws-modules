variable "cluster_name" {
    description = "The name of the EKS cluster."
    type        = string
    default     = ""

    validation {
        condition     = length(var.cluster_name) > 0
        error_message = "The cluster name must be provided."
    }
  
}

variable "fargate_profile_name" {
  description = "The fargate profile name."
  type        = string
  default     = ""

  validation {
    condition     = length(var.fargate_profile_name) > 0
    error_message = "The fargate profile name must be provided."
  }
}

variable "pod_execution_role_arn" {
  description = "The ARN of the IAM role that provides permissions for the Fargate pods."
  type        = string
  default     = ""

  validation {
        condition     = length(var.pod_execution_role_arn) > 0
        error_message = "The pod execution role ARN must be provided."
    }
  
}

variable "subnet_ids" {
  description = "Subnet ID's of VPC Where the cluster has been created"
  type        = list(string)
  default     = [""]

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "The subnet IDs must be provided."
  }
}

variable "namespace" {
  description = "The namespace to which the Fargate profile applies."
  type        = string
  default     = ""

  validation {
    condition     = length(var.namespace) > 0
    error_message = "The namespace must be provided."
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
      for value in values(var.default_tags) : 
        can(regex("^[a-z0-9-]*$", value)) && length(value) <= 100
    ]) && (contains([""], var.default_tags["Environment"]) || contains(["dev", "stage", "prod", "test", "qa"], var.default_tags["Environment"]))
    error_message = <<EOT
      - Tag values must be 1-100 characters long, contain only lowercase letters, numbers, and hyphens (-), and cannot contain spaces or underscores (_).
      - Environment tag can be empty or must be one of the allowed values ["dev", "stage", "prod", "test", "qa"].
      EOT
  }
}