data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"] # Amazon

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  common_tags = {
    Cluster   = var.cluster_name
    ManagedBy = "terraform"
  }

  # Minimal user-data — k8s installation is handled by Ansible post-provision.
  node_userdata = <<-EOF
    #!/bin/bash
    set -e
    hostnamectl set-hostname "$(curl -s http://169.254.169.254/latest/meta-data/local-hostname)"
  EOF
}

resource "aws_instance" "control_plane" {
  for_each = var.manager_nodes

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = each.value.instance_type
  subnet_id              = var.private_subnet_ids[each.value.az_index]
  vpc_security_group_ids = [var.sg_cp_id]
  key_name               = var.key_name
  iam_instance_profile   = var.instance_profile_name

  user_data = local.node_userdata

  root_block_device {
    volume_size           = each.value.disk_size_gb
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-cp-${each.key}"
    Role = "control-plane"
  })
}

resource "aws_instance" "worker" {
  for_each = var.worker_nodes

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = each.value.instance_type
  subnet_id              = var.private_subnet_ids[each.value.az_index]
  vpc_security_group_ids = [var.sg_worker_id]
  key_name               = var.key_name
  iam_instance_profile   = var.instance_profile_name

  user_data = local.node_userdata

  root_block_device {
    volume_size           = each.value.disk_size_gb
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-worker-${each.key}"
    Role = "worker"
  })
}
