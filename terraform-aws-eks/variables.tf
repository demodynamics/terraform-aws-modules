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

variable "endpoint_public_access" {
  description = "Enable public access to the EKS API server endpoint"
  type        = bool
  default     = true
}

variable "endpoint_private_access" {
  description = "Enable private access to the EKS API server endpoint"
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "CIDR blocks to allow public access to the EKS API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"] # All IPs can access the public endpoint. Can be set to an empty list [], meaning no public access. or can be set to specific CIDR blocks`YOUR_OFFICE_IP/32

  /*
If you want to omit public_access_cidrs (i.e., not set it at all):
In your root module, do not set it, and in your variable definition, do not use [""] as the default.
Instead, use [] (an empty list) as the default:
This way, if you don’t set it, Terraform will pass an empty list, which means the attribute is not set and AWS will use its default (usually 0.0.0.0/0).
*/


  validation {
    condition = alltrue([
      for cidr in var.public_access_cidrs :
      can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", cidr))
    ])
    error_message = "Each CIDR block must be in the format x.x.x.x/x (e.g., 192.168.1.0/24)."
  }

}


# cluster_policy_log_types block variables
# This block is used to configure EKS cluster control plane logging.
# It is optional and can be enabled or disabled based on the user's requirements.
# If enabled, it allows for additional configuration of log types to enable.
# If not enabled, EKS will not create CloudWatch log groups for the specified log types.
# Note: The cluster_policy_log_types_eabled variable is a boolean that determines whether the cluster_policy_log_types block is
# enabled or not. If set to true, the cluster_policy_log_types variable must be provided.
# If set to false, the cluster_policy_log_types block will not be created,
# and EKS will not create CloudWatch log groups for the specified log types.
# The cluster_policy_log_types variable is a list of EKS cluster control plane log types to enable.
# The default log types include "api", "audit", "authenticator", "controllerManager", and "scheduler".
# Ensure that the log types are valid and supported by EKS.
# The log types must be alphabetic characters only.
# If you do not specify any log types, EKS will not create CloudWatch log groups for the specified log types.
# The log types are case-sensitive and must match the EKS documentation.
# The log types can be enabled or disabled based on the user's requirements.
# The log types can be used to monitor and troubleshoot the EKS cluster control plane.
variable "cluster_policy_log_types_eabled" {
  description = "Enable EKS cluster control plane logging"
  type        = bool
  default     = false

}

variable "cluster_policy_log_types" {
  description = "List of EKS cluster control plane log types to enable"
  type        = list(string)
  default = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  validation {
    condition     = alltrue([for log_type in var.cluster_policy_log_types : can(regex("^[a-zA-Z]+$", log_type))])
    error_message = "All log types must be alphabetic characters only."
  }
}


# encryption_config block variables
# This block is used to configure encryption of Kubernetes secrets with KMS in EKS.
# It is optional and can be enabled or disabled based on the user's requirements.
# If enabled, it allows for additional configuration of encryption resources and the KMS key ARN.
# If not enabled, EKS will use the default KMS key for your account.
# Note: The encryption_config_enabled variable is a boolean that determines whether the encryption_config block is
# enabled or not. If set to true, the encryption_config_resources and kms_key_arn variables must be provided.
# If set to false, the encryption_config block will not be created,
# and EKS will use the default KMS key for your account.
# If you do not specify a KMS key, EKS will use the default KMS key for your account.
# The encryption_config_resources variable is a list of resources to encrypt with KMS in EKS.
# The kms_key_arn variable is the ARN of the KMS key used for encrypting Kubernetes secrets in EKS.
# Ensure that the KMS key has the necessary permissions for EKS to use it
# for encryption and decryption.
variable "encryption_config_enabled" {
  description = "Enable encryption of Kubernetes secrets with KMS in EKS"
  type        = bool
  default     = false

}

variable "encryption_config_resources" {
  description = "List of resources to encrypt with KMS in EKS"
  type        = list(string)
  default     = ["secrets"]

  validation {
    condition     = alltrue([for resource in var.encryption_config_resources : can(regex("^[a-zA-Z]+$", resource))])
    error_message = "All resources must be alphabetic characters only."
  }
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for EKS secrets encryption"
  type        = string
  default     = ""

}

# access_config block variables
# This block is used to configure access to the EKS cluster, including authentication mode and permissions
# It is optional and can be enabled or disabled based on the user's requirements.
# If enabled, it allows for additional configuration of access control, such as setting the authentication mode
# and granting admin permissions to the bootstrap cluster creator.
variable "access_config_enabled" {
  description = "Enable EKS access configuration"
  type        = bool
  default     = false

}

variable "access_config_authentication_mode" {
  description = "Authentication mode for EKS access configuration"
  type        = string
  default     = "API"
}

variable "access_config_bootstrap_cluster_creator_admin_permissions" {
  description = "Enable admin permissions for bootstrap cluster creator in EKS access configuration"
  type        = bool
  default     = true
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
