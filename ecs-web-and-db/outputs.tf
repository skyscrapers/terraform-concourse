output "elb_dns_name" {
  value = "${module.elb.elb_dns_name}"
}

output "elb_zone_id" {
  value = "${module.elb.elb_zone_id}"
}

output "elb_sg_id" {
  value = "${module.elb.sg_id}"
}

output "iam_role_arn" {
  value = "${aws_iam_role.concourse_task_role.arn}"
}

output "concourse_rds_address" {
  value = "${module.concourse_rds.rds_address}"
}