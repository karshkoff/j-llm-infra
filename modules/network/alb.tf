# ALB for EKS

resource "aws_lb" "main" {
  name               = "${var.tags.project}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_01.id, aws_subnet.public_02.id]

  tags = merge(var.tags, { Name = "${var.tags.project}-alb" })
}

resource "aws_lb_target_group" "main" {
  name     = "${var.tags.project}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(var.tags, { Name = "${var.tags.project}-tg" })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

data "aws_acm_certificate" "cert" {
  domain   = "*.${var.domain_name}"
  statuses = ["ISSUED"]
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# Security Group for ALB

resource "aws_security_group" "alb_sg" {
  name        = "${var.tags.project}-alb-sg"
  description = "Security group for eks ingress"
  vpc_id      = aws_vpc.main.id

  tags = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "specific_ip_tls_ipv4" {
  security_group_id = aws_security_group.alb_sg.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "188.91.152.191/32"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # All protocols
}

# Attach EKS nodes to the target group

data "aws_instances" "eks_nodes" {
  instance_tags = {
    "eks:nodegroup-name" = "${var.tags.project}-eks-cluster-node-group"
  }
}

data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_lb_target_group_attachment" "eks_nodes" {
  for_each         = toset(data.aws_instances.eks_nodes.ids)
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = each.value
  port             = 30080
}

resource "aws_route53_record" "alb-record" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "llm.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}