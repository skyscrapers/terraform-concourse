output "private_app_subnets" {
  value = ["${module.vpc.private_app_subnets}"]
}

output "rds_security_group" {
  value = "${module.postgres.rds_sg_id}"
}

output "ecs_cluster_name" {
  value = "${module.ecs_cluster.cluster_name}"
}

output "sg_all_id" {
  value = "${module.general_security_groups.sg_all_id}"
}

output "ecs-instance-profile" {
  value = "${module.ecs_cluster.ecs-instance-profile}"
}

output "ecs-service-role" {
  value = "${module.ecs_cluster.ecs-service-role}"
}

output "sg_ecs_instance" {
  value = "${aws_security_group.sg_ecs_instance.id}"
}

output "target_group_arn" {
  value = "${module.alb.target_group_arn}"
}

output "rds_password" {
  value = "${var.rds_password["${terraform.env}"]}"
}

output "rds_address" {
  value = "${module.postgres.rds_address}"
}

output "elb_id" {
  value = "${module.elb.elb_id}"
}
