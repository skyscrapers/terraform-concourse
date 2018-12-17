output "worker_instances_sg_id" {
  description = "Security group ID used for the worker instances"
  value       = "${aws_security_group.worker_instances_sg.id}"
}

output "worker_iam_role" {
  description = "Role name of the worker instances"
  value       = "${aws_iam_role.concourse_worker_role.name}"
}

output "worker_iam_role_arn" {
  description = "Role ARN of the worker instances"
  value       = "${aws_iam_role.concourse_worker_role.arn}"
}

output "worker_autoscaling_group_id" {
  description = "The Concourse workers autoscaling group ARN"
  value       = "${aws_autoscaling_group.concourse_worker_asg.id}"
}

output "worker_autoscaling_group_name" {
  description = "The Concourse workers autoscaling group name"
  value       = "${aws_autoscaling_group.concourse_worker_asg.name}"
}

output "worker_autoscaling_group_arn" {
  description = "The AWS region configured in the provider"
  value       = "${aws_autoscaling_group.concourse_worker_asg.arn}"
}

output "concourse_version" {
  description = "Concourse version deployed"
  value       = "${local.concourse_version}"
}
