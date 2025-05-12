# Create Kubernetes Service Account: A Service Account provides an identity for processes that run in a Pod.
resource "kubernetes_service_account" "service_account" {
  metadata {
    name        = var.service_account_name # Service Account name
    namespace   = var.service_account_namespace # Namespace in cluster wher will be Service Account Created
    annotations = {
      "eks.amazonaws.com/role-arn" = var.irsa_arn # IRSA Arn that gives service account permissions defined in policy(s) attached to IRSA
    }

    labels      = {
      app = var.service_account_name # Label for the service account
    }
  }
  automount_service_account_token = false # Automatically mount a token for the service account

}



/*
automount_service_account_token = true controls whether a Kubernetes service account will 
automatically mount a token (a type of credential) into the pods that use this service account.

🔍 What does it actually do?
When a pod uses a service account, Kubernetes (by default) mounts a token in the pod at this 
path:
/var/run/secrets/kubernetes.io/serviceaccount/token
This token is a JWT used by the pod to authenticate with the Kubernetes API server.

✅ When to use automount_service_account_token = true?
Use it when your pod needs to interact with the Kubernetes API, for example:
  External Secrets Operator
  Fluentd/Prometheus when scraping from Kubernetes
  Custom workloads that read ConfigMaps/Secrets from the cluster

❌ When to set it to false?
Set it to false for least privilege security if:
  Your pod does not need to talk to the Kubernetes API
  You're using IRSA to access AWS services only, and not Kubernetes

Example use case where you'd disable:
  automount_service_account_token = false
If your app just needs to access ECR or S3 using the IRSA IAM role, and not Kubernetes API, 
then this helps reduce unnecessary exposure of a Kubernetes token.

🛡️ TL;DR:
Setting	Behavior
true (default)	Mounts Kubernetes API token into pod
false	Avoids mounting token, more secure if not needed


The labels = { app = var.service_account_name } block in your Kubernetes service account 
resource is a metadata label attached to the service account object.

🔍 What it does:
It adds a Kubernetes label like this:
  metadata:
    labels:
      app: ecr-access
Assuming var.service_account_name = "ecr-access".

✅ Why use labels?
Labels are key-value pairs used to:

Organize and categorize Kubernetes objects
Filter or select objects using kubectl or Kubernetes controllers
Enable automation and monitoring tools to discover resources (e.g., Prometheus)
Allow for label selectors in workloads like NetworkPolicies, RoleBindings, etc.

⚙️ Example Use:
  kubectl get serviceaccounts -l app=ecr-access
  This command lists all service accounts with label app=ecr-access.

🧠 TL;DR:
Adding:

labels = {
  app = var.service_account_name
}
is just a helpful way to tag the service account with a label like app=ecr-access, which 
improves visibility and enables selection/filtering in Kubernetes.
*/