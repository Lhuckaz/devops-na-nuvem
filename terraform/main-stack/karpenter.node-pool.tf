data "http" "node_pool_crd" {
  url = "https://raw.githubusercontent.com/aws/karpenter-provider-aws/${jsondecode(data.http.karpenter_latest_version.response_body)["tag_name"]}/pkg/apis/crds/karpenter.sh_nodepools.yaml"
}

resource "kubernetes_manifest" "node_pool_crd" {
  manifest = yamldecode(data.http.node_pool_crd.response_body)
  depends_on = [
    aws_eks_node_group.this
  ]
}

resource "kubernetes_manifest" "node_pool" {
  manifest = yamldecode(file("./manifest/karpenter.node-pool.yaml"))
  depends_on = [
    kubernetes_manifest.node_pool_crd, kubernetes_manifest.node_class
  ]
}
