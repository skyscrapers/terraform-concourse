output "elb_dns_name" {
  description = "DNS name of the loadbalancer"
  value       = module.elb.elb_dns_name
}

output "elb_zone_id" {
  description = "Zone ID of the ELB"
  value       = module.elb.elb_zone_id
}

output "elb_sg_id" {
  description = "Security group id of the loadbalancer"
  value       = module.elb.sg_id
}

output "concourse_hostname" {
  description = "Final Concourse hostname"
  value       = local.concourse_hostname
}

output "concourse_version" {
  description = "Concourse version deployed"
  value       = local.concourse_version
}

output "iam_role_arn" {
  description = "ARN of the IAM role created for the Concourse ECS task"
  value       = aws_iam_role.concourse_task_role.arn
}

output "ecs_service_name" {
  description = "ECS Service Name of concourse web"
  value       = aws_ecs_service.concourse_web.name
}

