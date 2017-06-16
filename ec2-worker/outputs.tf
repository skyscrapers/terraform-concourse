output "worker_instances_sg_id" {
  value = "${aws_security_group.worker_instances_sg.id}"
}

output "worker_iam_role" {
  value = "${aws_iam_role.concourse_worker_role.name}"
}
