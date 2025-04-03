/*
length(var.github_oidc_arn) > 0: Ensures the ARN is not an empty string.
can(regex("^arn:aws:iam::\\d{12}:oidc-provider/.+", var.github_oidc_arn)): Checks that the ARN follows the pattern of an AWS IAM OIDC provider ARN.
\d{12} ensures the AWS account ID is exactly 12 digits.
oidc-provider/.+ ensures the ARN points to an OIDC provider.
*/

variable "github_oidc_arn" {
  description = "The ARN of the GitHub IAM OIDC Identity Provider (idP)"
  type        = string
  default     = ""

  validation {
    condition     = length(var.github_oidc_arn) > 0 && can(regex("^arn:aws:iam::\\d{12}:oidc-provider/.+", var.github_oidc_arn))
    error_message = "The github_oidc_arn must be a valid AWS IAM OIDC provider ARN (e.g., arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com)."
  }
}

variable "github_oidc_issuer_url" {
  description = "GitHub OIDC Provider URL"
  type        = string
  default     = "https://token.actions.githubusercontent.com"
}

variable "github_oidc_thumbprint_list" {
  description = "GitHub OIDC Provider's certificate thumbprints"
  type        = set(string)
  default     = [ "1f2ab83404c08ec9ea0bb99daed02186b091dbf4" ]
}

variable "github_username" {
  description = "GitHub account username which selected branch(es) from seletced repository will assume the role"
  type        = string
  default     = "demodynamics"
  validation {
    condition     = length(var.github_username) > 0
    error_message = "Please provide a valid GitHub username."
  }
}

variable "github_repo" {
  description = "Repository of selected GitHub account which branch(es) will assume the role"
  type        = string
  default     = "*"

  validation {
    condition     = length(var.github_repo) > 0
    error_message = "Please provide a valid GitHub repository name."
  }
}

variable "github_branch" {
  description = "Branch(es) of selected GitHub account's repository that will assume the role"
  type        = string
  default     = "*" # all branches of ${var.github_repo} repository can assume the role

  validation {
    condition     = length(var.github_branch) > 0
    error_message = "Please provide a valid GitHub branch name."
  }
}

variable "self_managed_policy_name" {
  description = "Custom Policy name that we create manually"
  type        = string
  default     = "EKSAccessPolicy"

  validation {
    condition     = length(var.self_managed_policy_name) > 0
    error_message = "Please provide a self managed policy name."
  }
  
}

variable "aws_manged_policies" {
  description = "AWS managed policy to attach to the role assumed by GitHub Actions"
  type        = set(string)
  default     = ["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"]

  validation {
    condition = alltrue([
      for policy in var.aws_manged_policies :
      can(regex("^arn:aws:iam::aws:policy/[a-zA-Z0-9_+=,.@-]+$", policy))  # Ensure correct AWS managed policy format
    ])
    error_message = "aws_manged_policies must follow the valid AWS managed IAM policy ARN format (e.g., arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser)."
  }
}


variable "self_managed_policy_permissions" {
  description = "Permissions set for Self Managed Policy"
  type        = set(string)
  default     = ["eks:DescribeCluster", "eks:ListClusters", "eks:AccessKubernetesApi"]

  validation {
    condition = alltrue([
      for perm in var.self_managed_policy_permissions :
      can(regex("^[a-zA-Z0-9-]+:[a-zA-Z0-9-*]+$", perm))  # Ensure correct IAM action format
    ])
    error_message = "self_managed_policy_permissions must follow the IAM action format (e.g., eks:DescribeCluster, s3:PutObject)."
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

Permissions for the Workflow:
        When Github Actions Workflow assumes the IAM Role by idenity token issued by GitHub OIDC provider, it needs to be granted access to interact with the 
        ECR Private Repositories, EKS cluster and EKS cluster's API. This ensures the workflow can push docker images into ECR Private Repositories, 
        update the kubeconfig file in the workflow, and use kubectl or Helm commands to apply changes (create/update resources)` apply Kubernetes resources to 
        the EKS cluster.
        
        This means the workflow needs to assume a role with permissions like ecr:AmazonEC2ContainerRegistryPowerUser (push docker images into ECR Private 
        Repository), eks:DescribeCluster (aws eks update-kubeconfig command to update the kubeconfig file)and eks:AccessKubernetesApi (to tell  The cluster's
        Kubernetes API processes these commands and updates the cluster as described in the manifests or Helm releases) and possibly other permissions for 
        managing resources, depending on our setup.

Github Actions Workflow needs these AWS managed permissions policies attached to the IAM role that Workflow assume by idenity token issued by GitHub OIDC 
provider:
    ecr:AmazonEC2ContainerRegistryPowerUser:
        Purpose:
            Allows the workflow to retrieve details about the ECR repositories and images.
        Why it’s needed:
            It’s required for the workflow to push docker images into ECR private repositories.   
    eks:DescribeCluster:
        Purpose: 
            Allows the workflow to retrieve details about the EKS cluster (e.g., endpoint, CA certificate, and other connection information).
        Why it’s needed: 
            It’s required for the aws eks update-kubeconfig command to update the kubeconfig file, which allows the workflow to interact with the cluster 
            using kubectl or Helm.
    eks:AccessKubernetesApi:
        Purpose: 
            Allows the workflow to interact with the Kubernetes API of the EKS cluster.
        Why it’s needed: 
            This is required for applying manifests or updating Helm releases in the cluster (i.e., performing actions like creating or modifying resources 
            such as pods, deployments, and services). It grants the necessary permissions to use kubectl or Helm to communicate with the Kubernetes API 
            server. We need access to the Kubernetes API (through kubectl or Helm) to deploy manifests and Helm charts to the EKS cluster.
                Key Point:
                To deploy or update resources in your EKS cluster, the workflow needs access to the Kubernetes API, inorder using kubectl or Helm through
                that API to tell the Kubernetes cluster what to do.
                    Here's how it works:
                        1.Access to Cluster API:
                            The workflow (e.g., via GitHub Actions) interacts with the Kubernetes API to manage resources in the cluster.
                            For That we need the files (like Kubernetes YAML manifests or Helm charts) in our repository.

                        2.What the Workflow Does:
                            It uses kubectl or Helm commands to apply Kubernetes resources (like deployments, services, etc.) to the cluster.
                            The cluster's Kubernetes API processes these commands and updates the cluster as described in the manifests or Helm releases.
    eks:ListClusters (Optional)
        Purpose: 
            Allows the workflow to list all the EKS clusters in the account.
        Why it’s useful: 
            This is not strictly necessary for updating the kubeconfig but is helpful if you want to dynamically discover clusters in the workflow or for 
            debugging purposes.

*/