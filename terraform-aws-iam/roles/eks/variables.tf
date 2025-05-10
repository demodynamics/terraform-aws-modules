variable "cluster_name" {
  description = "EKS Cluster Name"
  type = string
  default = "main"

  validation {
    condition = can(regex("^[a-z0-9-]{1,64}$", var.cluster_name))
    error_message = "cluster_name must be between 1 and 64 characters, and can only contain lowercase letters, numbers, and hyphens."
  }
}

variable "policies" {
  description = "List of AWS managed permissions policy(s) for Cluster Role"
  type        = set(string)
  default     = ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy", "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController", "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"]
  
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
When Both NodeGroup Role and IRSA Have AmazonEC2ContainerRegistryReadOnly Policy:
  When you attach AmazonEC2ContainerRegistryReadOnly to both the:

✅ Node group IAM role (for EC2 nodes), and

✅ IRSA-linked IAM role (for the Kubernetes service account used by your pods),

then:

🔐 IRSA takes priority — but only for pods that use the IRSA-enabled service account.
So:

          Pod Type	                       Priority IAM Role
System pods (CoreDNS, kube-proxy)	        Node group IAM role
Your pod using ecr-access	                IRSA IAM role (via service account) ✅
Your pod using default SA	                Node group IAM role

🔁 Why This Design Matters
The node IAM role is always available, which ensures the cluster can start and function.
The IRSA role is more secure and scoped only to specific pods that need specific permissions.

  NodeGroup Role: If the node group role has the AmazonEC2ContainerRegistryReadOnly policy and pod is NOT using IRSA IAM role (via service account) then 
  the nodes will pull images from ECR when the pods are scheduled on them using Nodegroup IAM role.
  
  IRSA: If the pod is using the IRSA IAM role (via service account) then the pod will pull images from ECR when the pods are scheduled on them using IRSA 
  IAM role.
  The nodes will not pull images from ECR in this case, since the pod has the necessary permissions to interact with ECR via IRSA.
  The nodes will still provide the infrastructure for running the pods, but the pods themselves will perform the image pull.



❗ But, During Node Group Creation, When a node group launches EC2 instances, those EC2s must:
  Download containerd, kubelet, and CNI binaries
  Pull ECR images (for core system pods too!)
  Communicate with EKS APIs

All of this happens before any pod or IRSA is in use.

So the IAM role (NodeGroup Role) attached to the EC2 node group itself must include:
  AmazonEKSWorkerNodePolicy
  AmazonEKS_CNI_Policy
  ✅ AmazonEC2ContainerRegistryReadOnly


  🔹 Node Group IAM Role: Applies to the EC2 instance
      Grants permissions to the EC2 host (node) itself.
      Used during bootstrapping, to pull system pods (like CoreDNS, kube-proxy) from ECR.
      Also used if pods do not use a service account with IRSA

🔹 IRSA (IAM Role for Service Account): Applies to specific pods
      Overrides the node IAM role only for pods that explicitly use the annotated service account.
      Is the most granular level of IAM control for Kubernetes workloads.
      Applies only after the pod is scheduled and running.

                                   ✅ Priority / Precedence
        Scenario	                             Pod uses IRSA?	       Permission Source
Core system pod (e.g. CoreDNS)	                   ❌ No	              Node IAM role
Your pod using default SA	                         ❌ No	              Node IAM role
Your pod using custom SA with IRSA	               ✅ Yes	            IRSA (Service Account IAM role)

✔️ So:
Keep AmazonEC2ContainerRegistryReadOnly on the Node IAM Role for bootstrapping and EKS system functionality.
Also assign it via IRSA if your app pods pull from ECR.
They don’t conflict — IRSA takes precedence for the pods that use it.

*/


/*

While both a Pod manifest and a Deployment manifest ultimately result in creating Pods, the key difference lies in management, scaling, and failure recovery.

Here’s a more detailed breakdown of the differences:

1.Pod Manifest:
    Basic Unit: A Pod manifest defines a single Pod (or a single unit of execution).
    No Replica Management: A Pod manifest doesn’t manage replication, scaling, or self-healing. If the Pod crashes or is deleted, it won’t be automatically recreated. You’d have to manually intervene to recreate it.
    Direct Scheduling: The Pod is directly scheduled to an available node in the cluster. If there are no available nodes, the Pod will remain in the Pending state.

      Example:

        apiVersion: v1
        kind: Pod
        metadata:
          name: my-pod
        spec:
          containers:
          - name: my-container
            image: nginx


2.Deployment Manifest:
    Higher-Level Abstraction: A Deployment manages a set of Pods and ensures that a specified number of replicas are running at all times.
    Self-Healing: If a Pod managed by a Deployment fails or is deleted, the Deployment controller will automatically create a new Pod to replace it and maintain the desired number of replicas.
    Scaling: A Deployment can scale Pods up or down. You can specify the number of replicas (Pods) to run, and Kubernetes will ensure that this number is always met.
    Rolling Updates: A Deployment can also manage rolling updates, allowing you to update the Pods without downtime by gradually replacing old Pods with new ones.

        Example:

          apiVersion: apps/v1
          kind: Deployment
          metadata:
            name: my-deployment
          spec:
            replicas: 3
            selector:
              matchLabels:
                app: my-app
            template:
              metadata:
                labels:
                  app: my-app
              spec:
                containers:
                - name: my-container
                  image: nginx


Key Differences:
  Scaling and Replication:
    Pod: A Pod manifest creates a single Pod. You would need to manually create additional Pods or manage replication.
    Deployment: A Deployment creates and manages multiple Pods (replicas) to ensure your application is always running with the desired number of Pods.

  Self-Healing:
    Pod: If a Pod crashes, it won’t be replaced automatically. You would need to manually recreate it.
    Deployment: A Deployment will automatically recreate Pods if they fail, ensuring the specified number of Pods is always running.

  Updates:
    Pod: No built-in support for rolling updates. You would need to manually handle updates by deleting and recreating Pods.
    Deployment: Supports rolling updates, so new versions of Pods can be deployed with no downtime.

Summary:
  Pod Manifest: Simple, single unit for creating a single Pod without management features.
  Deployment Manifest: Higher-level controller that manages multiple Pods, scaling, and auto-recovery features.

Both require nodes in the cluster to schedule the Pods, but the Deployment provides more features for managing and maintaining Pods in a reliable and scalable way.




*/
