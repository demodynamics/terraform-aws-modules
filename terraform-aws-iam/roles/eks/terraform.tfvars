cluster_role_policy = ["AmazonEKSClusterPolicy", "AmazonEKSVPCResourceController", "AmazonEKSServicePolicy"]

default_tags = {
  Owner = "Demo Dynamics"
  Environment = "Dev"
  Project = "Alco24"
}

/*
When Both NodeGroup Role and IRSA Have AmazonEC2ContainerRegistryReadOnly Policy:
  NodeGroup Role: If the node group role has the AmazonEC2ContainerRegistryReadOnly policy, then the nodes will pull images from ECR when the pods are 
  scheduled on them.
  IRSA: Even though the pods also have the permission via IRSA, the nodes will pull the image first, since they’re the ones responsible for pulling the image 
  onto the underlying EC2 instance before the pod can run on it.
In this case, the nodes handle the pulling because they have the necessary permissions to interact with ECR.

When NodeGroup Role Doesn't Have AmazonEC2ContainerRegistryReadOnly Policy, But IRSA Does:
  NodeGroup Role: If you remove the ECR pull permissions from the node group role, then the nodes won’t be able to pull images from ECR.
  IRSA: Since the pods have the AmazonEC2ContainerRegistryReadOnly permission via IRSA, they will be able to pull images directly from ECR.
    The pods themselves will perform the image pull, not the nodes. The nodes still provide the infrastructure for running the pods, but pods now handle the 
    image pulling directly.

Summary:
  If both the node group role and IRSA have the AmazonEC2ContainerRegistryReadOnly policy, nodes pull the images (since they are responsible for pulling 
  images to run the pods).
  If node group role doesn’t have the AmazonEC2ContainerRegistryReadOnly policy, pods will directly pull the images via IRSA, even though the nodes cannot.
This gives you flexibility and fine-grained control over which part of the system (node vs pod) can access ECR.


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