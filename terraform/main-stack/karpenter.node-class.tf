data "http" "node_class_crd" {
  url = "https://raw.githubusercontent.com/aws/karpenter-provider-aws/${jsondecode(data.http.karpenter_latest_version.response_body)["tag_name"]}/pkg/apis/crds/karpenter.k8s.aws_ec2nodeclasses.yaml"
}

resource "kubernetes_manifest" "node_class_crd" {
  manifest = yamldecode(data.http.node_class_crd.response_body)
  depends_on = [
    aws_eks_node_group.this
  ]
}

resource "kubernetes_manifest" "node_class" {
  manifest = yamldecode(templatefile("./manifest/karpenter.node-class.yaml", { node_group_role_name = aws_iam_role.eks_node_group.name, cluster_name = aws_eks_cluster.this.id }))
  depends_on = [
    aws_eks_node_group.this
  ]
}
