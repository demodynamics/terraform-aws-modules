variable "tls_private_key_algorithm" {
  description = "Algorithm for the TLS private key. Default is RSA."
  type        = string
  default     = "RSA"

}

variable "tls_private_key_bits" {
  description = "Number of bits for the key. Default is 4096."
  type        = number
  default     = 4096
}

variable "aws_key_pair_name" {
  description = "Name of the AWS EC2 key pair to create."
  type        = string
  default     = "ec2-ssh-key"

}

variable "key_name_suffix" {
  description = "Optional suffix for key rotation/versioning, e.g. -2025-07"
  type        = string
  default     = ""
}

variable "write_local_file" {
  type    = bool
  default = true
}

variable "ssh_private_key_filename" {
  description = "Filename to save the private key. Default is eks-ssh-key.pem."
  type        = string
  default     = "./ec2-ssh-key.pem"

}

variable "ssh_private_key_file_permission" {
  description = "File permission for the private key file. Default is 0400."
  type        = string
  default     = "0400"

}

variable "ssh_private_key_directory_permission" {
  description = "Directory permission for the private key file. Default is 0700."
  type        = string
  default     = "0700"

}

variable "tags" {
  type = map(string)
  default = {
    Owner       = "karen"
    CreatedBy   = "terraform"
    Project     = "ansible-test"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
