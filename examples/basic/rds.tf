module "postgres" {
  source                         = "github.com/skyscrapers/terraform-rds//rds?ref=4.0.0"
  vpc_id                         = "${module.vpc.vpc_id}"
  subnets                        = "${module.vpc.private_db_subnets}"
  project                        = "${var.project}-concourse"
  environment                    = "${var.environment}"
  size                           = "${var.db_instance_type}"
  security_groups                = ["${aws_security_group.sg_ecs_instance.id}"]
  security_groups_count          = 1
  rds_password                   = "${var.rds_root_password}"
  multi_az                       = false
  engine                         = "postgres"
  storage_encrypted              = "${var.rds_storage_encrypted}"
  engine_version                 = "${var.db_engine_version}"
  default_parameter_group_family = "${var.default_parameter_group_family}"
  storage                        = "${var.rds_allocated_storage}"
  apply_immediately              = true
  skip_final_snapshot            = true
}

resource "aws_security_group_rule" "sg_ecs_instances_postgres_out" {
  security_group_id        = "${aws_security_group.sg_ecs_instance.id}"
  type                     = "egress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = "${module.postgres.rds_sg_id}"
}
