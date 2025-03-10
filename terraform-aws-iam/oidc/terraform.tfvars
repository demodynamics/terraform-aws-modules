oidc_provider_url = "token.actions.githubusercontent.com"
oidc_audience = ["sts.amazonaws.com"]
thumbprint_list =  ["1f2ab83404c08ec9ea0bb99daed02186b091dbf4"]
oidc_service_name  = "GithubActions"
sub_condition = ["repo:demodynamics/alco244:*"]
aws_manged_policies = ["AmazonEC2ContainerRegistryPowerUser"]
self_managed_policy_permissions = ["eks:DescribeCluster","eks:ListClusters", "eks:AccessKubernetesApi"]
self_managed_policy_name = "EKSAccessPolicy"


default_tags = {
  Owner = "Demo Dynamics"
  Environment = "Dev"
  Project = "alco24"
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