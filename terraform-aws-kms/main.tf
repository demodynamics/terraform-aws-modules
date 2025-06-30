resource "aws_kms_key" "eks" {
  description             = "KMS key for EKS secrets encryption"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation
}


/*
- **deletion_window_in_days = 10**  
  When you schedule this KMS key for deletion, AWS will wait 10 days before actually deleting it.  
  This gives you a safety window to cancel the deletion if it was done by mistake.  
  (You can set this between 7 and 30 days.)

- **enable_key_rotation = true**  
  This enables automatic annual rotation of the cryptographic material for the KMS key.  
  It improves security by ensuring the key is changed every year, reducing the risk if a key is ever compromised.

**Summary:**  
- deletion_window_in_days: Safety delay before key deletion.  
- enable_key_rotation: Automatically rotates the key every year for better security.
*/

resource "aws_kms_alias" "eks" {
  name          = var.aws_kms_alias_name
  target_key_id = aws_kms_key.eks.key_id
}


/*The alias (name = "alias/eks-secrets") is used to give your KMS key a friendly, human-readable name.

**Why use an alias?**
- Easier to reference: Instead of using the long, random KMS key ID, you can use the alias in scripts, policies, or the AWS Console.
- Clarity: It helps you and your team quickly identify the purpose of the key (e.g., for EKS secrets).
- Flexibility: You can change the alias to point to a new key in the future without updating all references to the key ID.

**Summary:**  
The alias is for convenience and clarity—it makes managing and referencing your KMS key much easier.*/


# Allow EKS to use the KMS key and grant admin access to users/roles
data "aws_iam_policy_document" "eks_kms" {
  statement {
    actions = var.kms_policy_permissions_for_eks
    # This allows EKS to use the KMS key for encryption and decryption
    # The actions include encrypting, decrypting, describing the key, and generating data keys
    # These permissions are necessary for EKS to manage secrets encryption
    # and decryption using the KMS key.
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = var.kms_admin_arns
    content {
      actions = var.kms_policy_permissions_for_iam_identity
      # This allows the specified IAM user or role to have admin permissions on the KMS key
      # The actions include all KMS operations, allowing full control over the key.
      # This is useful for managing the KMS key, such as updating its policy or deleting
      # it when no longer needed.
      # The principals are specified as a list of IAM user or role ARNs.
      effect = "Allow"
      principals {
        type        = "AWS"
        identifiers = [statement.value]
      }
      resources = ["*"]
    }
  }
}

resource "aws_kms_key_policy" "eks" {
  key_id = aws_kms_key.eks.id
  policy = data.aws_iam_policy_document.eks_kms.json
  # This policy document grants the necessary permissions to EKS to use the KMS key for secrets encryption
  # and allows specified IAM users or roles to have admin access to the KMS key.
}

/*
KMS key policies are not attached to IAM identities (users, roles, or groups) like standard IAM policies. Instead:
    - **KMS key policies** are attached directly to the KMS key itself.
    - They define who (IAM users, roles, AWS services, etc.) can use the key and what actions they can perform.
    - You can grant permissions to AWS services (like EKS), IAM users, or roles within the key policy.

**Summary:**  
KMS key policies are resource-based policies attached to the key, not to an IAM identity. This is how you allow EKS
(or any AWS service) to use your KMS key.*/
