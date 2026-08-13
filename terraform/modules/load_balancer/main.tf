locals {
  common_tags = {
    Cluster   = var.cluster_name
    ManagedBy = "terraform"
  }
}

# ---------------------------------------------------------------------------
# Internal NLB — k8s API server HA endpoint (kubeadm --control-plane-endpoint)
# ---------------------------------------------------------------------------
resource "aws_lb" "api" {
  name               = "${var.cluster_name}-api-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.private_subnet_ids

  tags = merge(local.common_tags, { Name = "${var.cluster_name}-api-nlb" })
}

resource "aws_lb_target_group" "api" {
  name        = "${var.cluster_name}-api-tg"
  port        = 6443
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    protocol = "TCP"
    port     = "6443"
  }

  tags = merge(local.common_tags, { Name = "${var.cluster_name}-api-tg" })
}

resource "aws_lb_target_group_attachment" "api" {
  for_each = var.cp_instance_ids

  target_group_arn = aws_lb_target_group.api.arn
  target_id        = each.value
  port             = 6443
}

resource "aws_lb_listener" "api" {
  load_balancer_arn = aws_lb.api.arn
  port              = 6443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}

# ---------------------------------------------------------------------------
# Internet-facing ALB — application / ingress traffic to worker nodes
# Production: add a 443 listener with an ACM certificate.
# ---------------------------------------------------------------------------
resource "aws_lb" "app" {
  name               = "${var.cluster_name}-app-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [var.sg_alb_id]

  tags = merge(local.common_tags, { Name = "${var.cluster_name}-app-alb" })
}

resource "aws_lb_target_group" "app" {
  name        = "${var.cluster_name}-app-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "80"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
  }

  tags = merge(local.common_tags, { Name = "${var.cluster_name}-app-tg" })
}

resource "aws_lb_target_group_attachment" "app" {
  for_each = var.worker_instance_ids

  target_group_arn = aws_lb_target_group.app.arn
  target_id        = each.value
  port             = 80
}

resource "aws_lb_listener" "app_http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
