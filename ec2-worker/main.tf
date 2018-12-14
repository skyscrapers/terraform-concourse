locals {
  concourse_version = "${var.concourse_version_override == "" ? var.concourse_version : var.concourse_version_override}"
}

resource "aws_security_group" "worker_instances_sg" {
  name        = "concourse_worker_${var.environment}_${var.name}"
  description = "Security group for the Concourse worker instances in ${var.environment}"
  vpc_id      = "${var.vpc_id}"

  tags = {
    Name        = "concourse_worker_${var.environment}_${var.name}"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "worker_instances_to_tsa" {
  security_group_id = "${aws_security_group.worker_instances_sg.id}"
  type              = "egress"
  from_port         = 2222
  to_port           = 2222
  protocol          = "TCP"

  # Can't target only the web ELB security group because is an internet facing ELB, so traffic goes outside the VPC
  cidr_blocks = ["0.0.0.0/0"]
}
