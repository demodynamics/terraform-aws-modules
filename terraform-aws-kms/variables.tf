variable "deletion_window_in_days" {
  description = "The number of days to retain the KMS key before deletion"
  type        = number
  default     = 10
}

variable "enable_key_rotation" {
  description = "Whether to enable automatic key rotation for the KMS key"
  type        = bool
  default     = true
}

variable "aws_kms_alias_name" {
  description = "The alias name for the KMS key"
  type        = string
  default     = "alias/eks-secrets"
}

variable "kms_policy_permissions_for_eks" {
  description = "The IAM policy document for the KMS key permissions"
  type        = set(string)
  default = [
    "kms:Encrypt",
    "kms:Decrypt",
    "kms:DescribeKey",
    "kms:GenerateDataKey*"
  ]
}

variable "kms_policy_permissions_for_iam_identity" {
  description = "The IAM policy document for admin permissions on the KMS key"
  type        = set(string)
  default = [
    "kms:*"
  ]

}

variable "kms_admin_arns" {
  description = "List of IAM user or role ARNs to grant admin access to the KMS key"
  type        = list(string)
  default     = []
}

/*If you do not set the kms_admin_arns attribute in your root module, Terraform will use the default value defined 
in your variables file:
So, if you don’t set it, it will be an empty list (`[]`).  
In this case, the dynamic block in policy document will not generate any admin statements, and no additional IAM 
users or roles will have admin access to the KMS key (other than the EKS service principal).

**Summary:**  
If you don’t set kms_admin_arns, only EKS will have access to the key—no extra admin permissions will be granted.  
This is safe and expected behavior.*/
