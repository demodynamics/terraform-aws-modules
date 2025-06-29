# ---------------------------------------------------------- EKS Cluster ---------------------------------------------------------- #
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.cluster_version
  tags     = var.default_tags

  vpc_config {
    subnet_ids              = var.subnet_ids
    security_group_ids      = var.security_group_ids # Attach your security groups
    endpoint_public_access  = false                  # The API server is not accessible from the public internet
    endpoint_private_access = true                   # The EKS API server endpoint is accessible from within your VPC (private IPs).
    # public_access_cidrs     = ["YOUR_OFFICE_IP/32"]  # Restrict public access if enabled (optional)

  }
  # Uncomment to logging for the EKS cluster control plane
  # This will create CloudWatch log groups for the specified log types.
  # You can choose to enable or disable specific log types based on your requirements.
  # enabled_cluster_log_types = [
  #   "api",
  #   "audit",
  #   "authenticator",
  #   "controllerManager",
  #   "scheduler"
  # ]

  # Uncomment and configure the following block to enable secrets encryption with KMS (recommended)
  # encryption_config {
  #   resources = ["secrets"]
  #   provider {
  #     key_arn = aws_kms_key.eks.arn
  #   }
  # }
}



/*
If you do not specify custom security groups for your EKS cluster in AWS, the cluster will use the default security group 
associated with the VPC where the cluster is created. This default security group is automatically created by AWS for each 
VPC and allows all inbound and outbound traffic between resources assigned to it, unless you modify its rules.

Tip:
For production environments, it's recommended to use custom security groups with more restrictive rules for better security.
*/


