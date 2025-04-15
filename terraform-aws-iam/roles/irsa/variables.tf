variable "oidc_provider_arn" {
  description = "The ARN of the OIDC Identity Provider of the cluster"
  type = string
  default = ""

  validation {
    condition     = can(regex("^arn:aws:iam::\\d{12}:oidc-provider/.+$", var.oidc_provider_arn))
    error_message = "The OIDC provider ARN must be in the format 'arn:aws:iam::<ACCOUNT_ID>:oidc-provider/<OIDC_ENDPOINT>'."
  }
}

variable "cluster_name" {
  description = "The name of the EKS cluster for which we are creating the IRSA"
  type = string
  default = "main"

  validation {
    condition     = length(var.cluster_name) > 0
    error_message = "The cluster name must be provided and cannot be empty."
  }
}

variable "service_account_namespace" {
  description = "Namespace of the cluster"
  type = string
  default = "default"

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.service_account_namespace)) && length(var.service_account_namespace) <= 63
    error_message = "The namespace must be a valid Kubernetes namespace name: 1-63 characters, lowercase letters, numbers, and dashes, but cannot start or end with a dash."
  }
    /*
^[a-z0-9]([-a-z0-9]*[a-z0-9])?$ → Ensures:
  Starts and ends with a lowercase letter or number.
  Can contain dashes (-) in between.
  length(var.namespace) <= 63 → Ensures it's at most 63 characters (Kubernetes limit).
  The error message guides users if the input is invalid.
This ensures the namespace is Kubernetes-compliant and avoids deployment issues
 
Kubernetes namespaces do not allow underscores (_) in their names. The valid characters for a namespace are:
  Lowercase letters (a-z)
  Numbers (0-9)
  Dashes (-) (but not at the start or end)
The regex I provided ensures this rule is enforced. If you try to use an underscore, Kubernetes will reject it.
*/
}

variable "service_account_name" {
  description = "Service account name of the cluster"
  type = string
  default = "ecr-access"

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.service_account_name)) && length(var.service_account_name) <= 253
    error_message = "The service account name must be 1-253 characters long, contain only lowercase letters, numbers, and dashes, and cannot start or end with a dash."
  }

  /*
  Regex Explanation:
    Starts and ends with a lowercase letter or number
    Allows dashes (-) in the middle
    Ensures length is ≤ 253 characters (Kubernetes limit)
This ensures your service account name is fully Kubernetes-compliant 
  */
}

variable "policies" {
  description = "IAM policies for IRSA to attach to the service account"
  type = set(string)
  default = ["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]

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

/*
Allowed Characters for IAM Role Names:
  Uppercase (A-Z)
  Lowercase (a-z)
  Numbers (0-9)
  Underscores (_)
  Hyphens (-)
  Equals (=)
  Commas (,)
  Periods (.)
  At signs (@)
IAM Role Name Limitations:
  Max Length: 64 characters
  No special prefixes required
  Underscores (_) are allowed (unlike Kubernetes)




Key Differences Compared to Kubernetes Names:
Feature	I                 IAM Role Name	       Kubernetes Namespace/Service Account
Uppercase A-Z	              ✅ Allowed	                ❌ Not Allowed
Underscores _	              ✅ Allowed	                ❌ Not Allowed
Special chars (= , . @)	    ✅ Allowed	                ❌ Not Allowed
Max Length	                 64 chars	                    63/253 chars
Since IAM role names allow underscores (_), your role_name variable can have them without issues!


*/