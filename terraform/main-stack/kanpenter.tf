data "http" "kanpenter_latest_version" {
  url = "https://api.github.com/repos/aws/karpenter-provider-aws/releases/latest"
}

resource "aws_ec2_tag" "this" {
  resource_id = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  key         = "karpenter.sh/discovery"
  value       = aws_eks_cluster.this.id
}

resource "helm_release" "kanpenter" {
  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = jsondecode(data.http.kanpenter_latest_version.response_body)["tag_name"]
  namespace  = "kube-system"

  values = [templatefile("./manifest/kanpenter.values.yaml", { node_group_name = aws_eks_node_group.this.node_group_name })]

  set = [
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = aws_iam_role.karpenter_controller.arn
    },
    {
      name  = "settings.clusterName"
      value = aws_eks_cluster.this.id
    },
    {
      name  = "controller.resources.requests.cpu"
      value = "1"
    },
    {
      name  = "controller.resources.requests.memory"
      value = "1Gi"
    },
    {
      name  = "controller.resources.limits.cpu"
      value = "1"
    },
    {
      name  = "controller.resources.limits.memory"
      value = "1Gi"
    }
  ]

  depends_on = [kubernetes_manifest.node_class_crd, kubernetes_manifest.node_pool_crd, kubernetes_manifest.node_claim_crd]
}
