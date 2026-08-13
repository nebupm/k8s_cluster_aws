output "sg_alb_id" {
  value = aws_security_group.alb.id
}

output "sg_cp_id" {
  value = aws_security_group.cp.id
}

output "sg_worker_id" {
  value = aws_security_group.worker.id
}
