variable "secret_name" {
  description = "Name of the AWS Secrets Manager's secret."
  type        = string
  default     = ""

  validation {
    condition     = length(var.secret_name) > 0 && length(var.secret_name) <= 512
    error_message = "The secret_name variable must not be empty."
  }

}

variable "secret_value" {
  description = "Value to be stored in AWS Secrets Manager's secret."
  type        = string
  default     = ""
  sensitive   = true # Marking as sensitive to avoid accidental exposure in logs or outputs.

  validation {
    condition     = length(var.secret_value) > 0
    error_message = "The secret_value variable must not be empty."
  }

}

variable "tags" {
  type = map(string)
  default = {
    Owner       = "karen"
    CreatedBy   = "terraform"
    Project     = "my-project"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
