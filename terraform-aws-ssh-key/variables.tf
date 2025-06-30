variable "tls_private_key_algorithm" {
  description = "Algorithm for the TLS private key. Default is RSA."
  type        = string
  default     = "RSA"

}

variable "tls_private_key_rsa_bits" {
  description = "Number of bits for the RSA key. Default is 4096."
  type        = number
  default     = 4096

}

variable "aws_key_pair_name" {
  description = "Name of the AWS EC2 key pair to create."
  type        = string
  default     = "eks-ssh-key"

}

variable "eks_ssh_private_key_filename" {
  description = "Filename to save the private key. Default is eks-ssh-key.pem."
  type        = string
  default     = "./eks-ssh-key.pem"

}

variable "eks_ssh_private_key_file_permission" {
  description = "File permission for the private key file. Default is 0400."
  type        = string
  default     = "0400"

}

variable "eks_ssh_private_key_directory_permission" {
  description = "Directory permission for the private key file. Default is 0700."
  type        = string
  default     = "0700"

}
