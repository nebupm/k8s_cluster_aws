locals {
  common_tags = {
    Cluster   = var.cluster_name
    ManagedBy = "terraform"
  }
}

resource "aws_security_group" "alb" {
  name        = "${var.cluster_name}-sg-alb"
  description = "Internet-facing ALB — HTTP/HTTPS from public"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.cluster_name}-sg-alb" })
}

resource "aws_security_group" "cp" {
  name        = "${var.cluster_name}-sg-cp"
  description = "Control plane nodes"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, { Name = "${var.cluster_name}-sg-cp" })
}

resource "aws_security_group" "worker" {
  name        = "${var.cluster_name}-sg-worker"
  description = "Worker nodes"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, { Name = "${var.cluster_name}-sg-worker" })
}

# k8s API server — reachable from ALB, peer CPs, and workers.
# NLBs in AWS do not have security groups; traffic arrives with the original source IP.
# Ensure this SG allows the private subnet CIDRs if the NLB subnet overlaps.
resource "aws_vpc_security_group_ingress_rule" "cp_api_from_alb" {
  security_group_id            = aws_security_group.cp.id
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 6443
  to_port                      = 6443
  ip_protocol                  = "tcp"
  description                  = "API server from ALB"
}

resource "aws_vpc_security_group_ingress_rule" "cp_api_from_cp" {
  security_group_id            = aws_security_group.cp.id
  referenced_security_group_id = aws_security_group.cp.id
  from_port                    = 6443
  to_port                      = 6443
  ip_protocol                  = "tcp"
  description                  = "API server peer CP"
}

resource "aws_vpc_security_group_ingress_rule" "cp_api_from_worker" {
  security_group_id            = aws_security_group.cp.id
  referenced_security_group_id = aws_security_group.worker.id
  from_port                    = 6443
  to_port                      = 6443
  ip_protocol                  = "tcp"
  description                  = "API server from workers"
}

resource "aws_vpc_security_group_ingress_rule" "cp_etcd" {
  security_group_id            = aws_security_group.cp.id
  referenced_security_group_id = aws_security_group.cp.id
  from_port                    = 2379
  to_port                      = 2380
  ip_protocol                  = "tcp"
  description                  = "etcd peer"
}

resource "aws_vpc_security_group_ingress_rule" "cp_kubelet_from_cp" {
  security_group_id            = aws_security_group.cp.id
  referenced_security_group_id = aws_security_group.cp.id
  from_port                    = 10250
  to_port                      = 10259
  ip_protocol                  = "tcp"
  description                  = "kubelet/scheduler/cm from peer CP"
}

resource "aws_vpc_security_group_ingress_rule" "cp_kubelet_from_worker" {
  security_group_id            = aws_security_group.cp.id
  referenced_security_group_id = aws_security_group.worker.id
  from_port                    = 10250
  to_port                      = 10259
  ip_protocol                  = "tcp"
  description                  = "kubelet from workers"
}

resource "aws_vpc_security_group_ingress_rule" "cp_ssh" {
  security_group_id = aws_security_group.cp.id
  cidr_ipv4         = var.ssh_allowed_cidr
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  description       = "SSH"
}

resource "aws_vpc_security_group_egress_rule" "cp_all" {
  security_group_id = aws_security_group.cp.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "worker_kubelet_from_cp" {
  security_group_id            = aws_security_group.worker.id
  referenced_security_group_id = aws_security_group.cp.id
  from_port                    = 10250
  to_port                      = 10250
  ip_protocol                  = "tcp"
  description                  = "kubelet from CP"
}

resource "aws_vpc_security_group_ingress_rule" "worker_nodeport_from_alb" {
  security_group_id            = aws_security_group.worker.id
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 30000
  to_port                      = 32767
  ip_protocol                  = "tcp"
  description                  = "NodePort range from ALB"
}

resource "aws_vpc_security_group_ingress_rule" "worker_self" {
  security_group_id            = aws_security_group.worker.id
  referenced_security_group_id = aws_security_group.worker.id
  from_port                    = 0
  to_port                      = 65535
  ip_protocol                  = "tcp"
  description                  = "Worker-to-worker (pod networking)"
}

resource "aws_vpc_security_group_ingress_rule" "worker_ssh" {
  security_group_id = aws_security_group.worker.id
  cidr_ipv4         = var.ssh_allowed_cidr
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  description       = "SSH"
}

resource "aws_vpc_security_group_egress_rule" "worker_all" {
  security_group_id = aws_security_group.worker.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
