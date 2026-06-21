output "autoscaling_group_name" {
  description = "Name of the single-instance Auto Scaling Group."
  value       = aws_autoscaling_group.instance.name
}

output "launch_template_id" {
  description = "Launch template used by the Auto Scaling Group."
  value       = aws_launch_template.instance.id
}

output "subnet_id" {
  description = "IPv6-enabled subnet used by the agent."
  value       = aws_subnet.default.id
}

output "vpc_id" {
  description = "Dedicated VPC used by the agent."
  value       = aws_vpc.default.id
}

output "tailscale_hostname" {
  description = "Tailscale hostname configured during bootstrap."
  value       = var.tailscale_hostname
}
