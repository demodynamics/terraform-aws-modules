variable "bucket_name" {
  description = "S3 Bucket Name"
  type = string
  default = ""

  validation {
    condition     = can(regex("^[a-z0-9-]{3,63}$", var.bucket_name)) && !can(regex("^-|-$", var.bucket_name))
    error_message = "The S3 bucket name must be between 3 and 63 characters long, contain only lowercase letters, numbers, and hyphens (-), and cannot start or end with a hyphen."
  }
}

variable "bucket_versioning_status" {
  description = "Enabling or Disabling S3 Bucket Versioning"
  type = bool
  default = true
}

variable "bucket_encryption" {
  description = "S3 Bucket Encryption type"
  type = string 
  default = "AES256"

  validation {
    condition     = can(regex("^(AES256|aws:kms)$", var.bucket_encryption))
    error_message = "The bucket_encryption must be either 'AES256' or 'aws:kms'."
  }
}

variable "custom_kms_key" {
  description = "Custom KMS Key arn"
  type = string
  default = ""

  validation {
    condition     = can(regex("^arn:aws:kms:[a-z0-9-]+:[0-9]{12}:key/[a-zA-Z0-9-]{1,64}$", var.custom_kms_key))
    error_message = "The custom_kms_key must be a valid KMS Key ARN in the format arn:aws:kms:<region>:<account-id>:key/<key-id>."
  }
  
}



