# provider "kubernetes" {
#   host                   = local.host
#   cluster_ca_certificate = local.cluster_ca_certificate
#   token                  = local.token
# }

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

# # ALB controller service account

# resource "kubernetes_service_account" "alb" {
#   metadata {
#     name      = "aws-load-balancer-controller"
#     namespace = "kube-system"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = "arn:aws:iam::${var.aws_account_id}:role/${var.alb_controller_role_name}"
#     }
#   }
# }

# ALB controller

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.13.0"

  set = [
    {
      name  = "clusterName"
      value = var.cluster_name
    },
    {
      name  = "serviceAccount.name"
      value = var.alb_controller_role_name
    },
    {
      name  = "vpcId"
      value = var.vpc_id
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = "arn:aws:iam::${var.aws_account_id}:role/${var.alb_controller_role_name}"
    },
  ]
}
