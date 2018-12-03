module "elb" {
  source                        = "github.com/skyscrapers/terraform-loadbalancers//elb_with_ssl_no_s3logs?ref=6.1.0"
  name                          = "${var.name}"
  subnets                       = ["${var.elb_subnets}"]
  project                       = "concourse"
  health_target                 = "http:8080/"
  backend_security_groups       = ["${var.backend_security_group_id}"]
  backend_security_groups_count = 1
  ssl_certificate_id            = "${var.ssl_certificate_id}"
  environment                   = "${var.environment}"
  instance_port                 = 2222
  instance_protocol             = "TCP"
  lb_port                       = 2222
  lb_protocol                   = "TCP"
  instance_ssl_port             = 8080
  instance_ssl_protocol         = "TCP"
  lb_ssl_port                   = 443
  lb_ssl_protocol               = "SSL"
  internal                      = false
  ingoing_allowed_ips           = ["${var.allowed_incoming_cidr_blocks}"]

  custom_listeners = [{
    instance_port     = "${var.concourse_prometheus_bind_port}"
    instance_protocol = "HTTP"
    lb_port           = "${var.concourse_prometheus_bind_port}"
    lb_protocol       = "HTTP"
  }]
}

# Allow TSA from ELB to ECS on ECS security group
resource "aws_security_group_rule" "sg_ecs_instances_elb_in_ssh" {
  security_group_id        = "${var.backend_security_group_id}"
  type                     = "ingress"
  from_port                = 2222
  to_port                  = 2222
  protocol                 = "tcp"
  source_security_group_id = "${module.elb.sg_id}"
}

resource "aws_security_group_rule" "sg_ecs_instances_elb_in_prometheus" {
  security_group_id        = "${var.backend_security_group_id}"
  type                     = "ingress"
  from_port                = "${var.concourse_prometheus_bind_port}"
  to_port                  = "${var.concourse_prometheus_bind_port}"
  protocol                 = "tcp"
  source_security_group_id = "${module.elb.sg_id}"
}

# Allow ATC from ELB to ECS on ECS security group
resource "aws_security_group_rule" "sg_ecs_instances_elb_in_http" {
  security_group_id        = "${var.backend_security_group_id}"
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = "${module.elb.sg_id}"
}

# Allow traffic to TSA from the ECS security group
resource "aws_security_group_rule" "sg_ecs_instances_elb_out_ssh" {
  security_group_id = "${var.backend_security_group_id}"
  type              = "egress"
  from_port         = 2222
  to_port           = 2222
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "sg_ecs_instances_elb_out_prometheus" {
  security_group_id        = "${module.elb.sg_id}"
  type                     = "egress"
  from_port                = "${var.concourse_prometheus_bind_port}"
  to_port                  = "${var.concourse_prometheus_bind_port}"
  protocol                 = "tcp"
  source_security_group_id = "${var.backend_security_group_id}"
}

resource "aws_security_group_rule" "sg_elb_in_prometheus" {
  count             = "${length(var.prometheus_cidrs) > 0 ? 1 : 0}"
  security_group_id = "${module.elb.sg_id}"
  type              = "ingress"
  from_port         = "${var.concourse_prometheus_bind_port}"
  to_port           = "${var.concourse_prometheus_bind_port}"
  protocol          = "tcp"
  cidr_blocks       = "${var.prometheus_cidrs}"
}
