module "ecs_cluster" {
  source      = "github.com/skyscrapers/terraform-ecs//ecs-cluster?ref=1.0.2"
  project     = "${var.project}"
  environment = "${terraform.env}"
}

resource "aws_security_group" "sg_ecs_instance" {
  name        = "sg_ecs_instance_${var.project}_${terraform.env}"
  description = "Security group that is needed for the ecs instance hosts"
  vpc_id      = "${module.vpc.vpc_id}"

  tags = {
    Name        = "${var.project}-${terraform.env}-sg_ecs_instance"
    Environment = "${terraform.env}"
    Project     = "${var.project}"
  }
}


resource "aws_security_group_rule" "sg_ecs_instances_alb_in" {
  security_group_id        = "${aws_security_group.sg_ecs_instance.id}"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = "${module.alb.sg_id}"
}

resource "aws_security_group_rule" "sg_ecs_instances_postgres_out" {
  security_group_id        = "${aws_security_group.sg_ecs_instance.id}"
  type                     = "egress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = "${module.postgres.rds_sg_id}"
}
