output "worker_instances_sg_id" {
  value = "${aws_security_group.worker_instances_sg.id}"
}
