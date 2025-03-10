variable "default_tags" {
  description = "Tags that are the same for all resources"
  type = map(string)
}

variable "bucket_versioning_status" {
  description = "Bucket Versioning Status"
  type = bool
}

variable "bucket_encryption" {
  description = "Bucket Encryption"
  type = string 
}



