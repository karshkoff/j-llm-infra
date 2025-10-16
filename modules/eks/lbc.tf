provider "helm" {
  kubernetes = {
    host                   = aws_eks_cluster.main.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.main.token
  }
}

data "aws_eks_cluster_auth" "main" {
  name = var.cluster_name
}

# ALB controller

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.14.0"
  values = [
    templatefile("${path.module}/config/lbc_values.yaml",
      {
        cluster_name             = var.cluster_name
        alb_controller_role_name = var.alb_controller_role_name
        vpc_id                   = var.vpc_id
        aws_account_id           = var.aws_account_id
      }
    )
  ]
}
