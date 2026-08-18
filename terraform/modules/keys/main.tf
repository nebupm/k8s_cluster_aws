resource "tls_private_key" "cluster" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "cluster" {
  key_name   = var.cluster_name
  public_key = tls_private_key.cluster.public_key_openssh
}

# SSM Parameter Store SecureString — KMS-encrypted, free for standard parameters (< 4 KB).
# ED25519 private keys are ~400 bytes, well within the standard tier limit.
resource "aws_ssm_parameter" "ssh_private_key" {
  name        = "/${var.cluster_name}/ssh-private-key"
  type        = "SecureString"
  value       = tls_private_key.cluster.private_key_openssh
  description = "SSH private key for ${var.cluster_name} cluster nodes"

  lifecycle {
    ignore_changes = [value]
  }
}
