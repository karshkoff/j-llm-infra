# ALB for EKS

resource "aws_lb" "main" {
  name               = "${var.tags.project}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_01.id, aws_subnet.public_02.id]

  tags = merge(var.tags,
    {
      Name                       = "${var.tags.project}-alb",
      "elbv2.k8s.aws/cluster"    = var.tags.project,
      "ingress.k8s.aws/stack"    = "${var.tags.project}/${var.tags.project}-ingress",
      "ingress.k8s.aws/resource" = "LoadBalancer",
    }
  )
}

# Route53 Record for ALB

data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "alb-record" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "chat.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}
