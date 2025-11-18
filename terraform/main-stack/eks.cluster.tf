resource "aws_eks_cluster" "this" {
  name                      = var.eks_cluster.name
  role_arn                  = aws_iam_role.eks_cluster.arn
  version                   = var.eks_cluster.version
  enabled_cluster_log_types = var.eks_cluster.enabled_cluster_log_types

  access_config {
    authentication_mode = var.eks_cluster.access_config_authentication_mode
  }

  vpc_config {
    subnet_ids = aws_subnet.private[*].id
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy]
}

# Provider Kubernetes autenticando no EKS
# provider "kubernetes" {
#   host                   = aws_eks_cluster.this.endpoint
#   cluster_ca_certificate = base64decode(aws_eks_cluster.this.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.this.token
# }

data "aws_eks_cluster_auth" "this" {
  name = aws_eks_cluster.this.name
}

# This resource grants the IAM user "lucas" an identity within EKS.
resource "aws_eks_access_entry" "lucas_user" {
  # Depends on the cluster being fully created.
  depends_on = [aws_eks_cluster.this]

  cluster_name  = aws_eks_cluster.this.name
  principal_arn = "arn:aws:iam::360466417573:user/lucas"
  type          = "STANDARD" # For IAM users/roles
}

# This resource associates the access entry with a Kubernetes permission group.
# AmazonEKSAdminPolicy provides full cluster admin rights.
resource "aws_eks_access_policy_association" "lucas_user_admin" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = aws_eks_access_entry.lucas_user.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}
