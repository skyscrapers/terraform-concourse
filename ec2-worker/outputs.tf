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
