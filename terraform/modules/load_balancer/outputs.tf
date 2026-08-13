output "api_nlb_dns_name" {
  description = "Internal NLB DNS — use as kubeadm --control-plane-endpoint"
  value       = aws_lb.api.dns_name
}

output "alb_dns_name" {
  description = "Public ALB DNS for application traffic"
  value       = aws_lb.app.dns_name
}
