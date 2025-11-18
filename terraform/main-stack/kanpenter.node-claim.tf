data "http" "node_claim_crd" {
  url = "https://raw.githubusercontent.com/aws/karpenter-provider-aws/${jsondecode(data.http.kanpenter_latest_version.response_body)["tag_name"]}/pkg/apis/crds/kanpenter.sh_nodeclaims.yaml"
}

resource "kubernetes_manifest" "node_claim_crd" {
  manifest = yamldecode(data.http.node_claim_crd.response_body)
  depends_on = [
    aws_eks_node_group.this
  ]
}
