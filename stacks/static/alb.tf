module "alb" {
  source                 = "github.com/skyscrapers/terraform-loadbalancers//alb_with_ssl_no_s3logs?ref=3d4b0a682f635b9db1ef8720d5ebc1c17094f709"
  vpc_id                 = "${module.vpc.vpc_id}"
  backend_security_group = "${aws_security_group.sg_ecs_instance.id}"
  subnets                = "${module.vpc.public_lb_subnets}"
  project                = "${var.project}"
  environment            = "${terraform.env}"
  backend_https_port     = "3000"
  name                   = "web"
  ssl_certificate_id     = "${var.alb_ssl_certificate["${terraform.env}"]}"
}

resource "aws_security_group_rule" "sg_alb_ecs_instances_in" {
  security_group_id        = "${module.alb.sg_id}"
  type                     = "egress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.sg_ecs_instance.id}"
}
