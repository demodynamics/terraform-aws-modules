# ---------------------------------------------------------- EKS Cluster ---------------------------------------------------------- #
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.cluster_version
  tags     = var.default_tags

  vpc_config {
    subnet_ids              = var.subnet_ids
    security_group_ids      = var.security_group_ids      # Attach your security groups
    endpoint_private_access = var.endpoint_private_access # The EKS API server endpoint is accessible from within your VPC (private IPs).
    endpoint_public_access  = var.endpoint_public_access  # The API server is not accessible from the public internet
    public_access_cidrs     = var.public_access_cidrs     # Restrict public access if enabled (optional)

  }

  access_config {
    authentication_mode                         = var.access_config_authentication_mode
    bootstrap_cluster_creator_admin_permissions = var.access_config_bootstrap_cluster_creator_admin_permissions
  }
  # Uncomment to logging for the EKS cluster control plane
  # This will create CloudWatch log groups for the specified log types.
  # You can choose to enable or disable specific log types based on your requirements.
  enabled_cluster_log_types = var.cluster_policy_log_types

  # Uncomment and configure the following block to enable secrets encryption with KMS (recommended)
  dynamic "encryption_config" {
    for_each = var.kms_key_arn != "" ? [var.kms_key_arn] : []
    # This is the ARN of the KMS key used for encrypting Kubernetes secrets in EKS.
    # Ensure that the KMS key has the necessary permissions for EKS to use it
    # for encryption and decryption.
    # If you do not specify a KMS key, EKS will use the default KMS key for your account.
    content {
      resources = var.encryption_config_resources
      provider {
        key_arn = encryption_config.value
      }
    }
  }

  /*
The dynamic block is used like this:

- If kms_key_arn is a non-empty string, the block is included.
- If kms_key_arn is empty, the block is omitted, and no error occurs.

**You do not need to make kms_key_arn variable a list or set.**  
Keep it as a string, and the dynamic block will handle the conditional logic for you.  
This is the recommended and standard approach for optional blocks in Terraform.

Here’s how it works in the dynamic block for encryption_config:

 In this case, the dynamic block is not iterating over a set or map—it's iterating over a list.

Here’s how it works in the dynamic block for encryption_config:

- If kms_key_arn is not an empty string, for_each gets a single-item list: [kms_key_arn].
- If kms_key_arn is empty, for_each gets an empty list: [].

In a dynamic block, you put a single string (like var.kms_key_arn) into a list ([var.kms_key_arn]) so that for_each can iterate over it if it’s set, or over an empty list if it’s not.
This is a standard Terraform pattern for making a nested block optional based on a single variable.


**Summary:**  
- You are not iterating over a set here, but over a list (either one item or zero items).
- This is a common Terraform idiom for optional blocks.  
- It works perfectly for a single string variable like kms_key_arn.


- In a dynamic block (for nested blocks inside a resource), for_each can iterate over a list, set, or map.
- In a resource block (for creating multiple resources), for_each can iterate over a set or map, but not a plain list. 
  If you use a list, Terraform will convert it to a set (removing duplicates and losing order).

**Summary:**  
- dynamic blocks: for_each works with lists, sets, or maps.  
- resource blocks: for_each works with sets or maps (not plain lists, but lists are converted to sets automatically).

So, for your dynamic block pattern, using a list (like [var.kms_key_arn]) is correct and standard!
*/

  lifecycle {
    prevent_destroy = var.prevent_destroy # Prevents the EKS cluster from being destroyed
  }
}



/*
If you do not specify custom security groups for your EKS cluster in AWS, the cluster will use the default security group 
associated with the VPC where the cluster is created. This default security group is automatically created by AWS for each 
VPC and allows all inbound and outbound traffic between resources assigned to it, unless you modify its rules.

Tip:
For production environments, it's recommended to use custom security groups with more restrictive rules for better security.
*/


