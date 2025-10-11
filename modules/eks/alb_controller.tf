
# ALB service account

provider "kubernetes" {
  host                   = aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.main.token
}

data "aws_eks_cluster_auth" "main" {
  name = var.cluster_name
}

resource "kubernetes_service_account" "alb" {
  metadata {
    labels = {
      "app.kubernetes.io/component" = "controller",
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
    }
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::${var.aws_account_id}:role/${var.alb_load_balancer_role_name}"
    }
  }
}