resource "aws_alb" "concourse-web" {
  name            = "${var.team}-${var.environment}"
  internal        = false
  security_groups = ["${var.security_groups}"]
  subnets         = ["${var.subnets}"]

  enable_deletion_protection = true

  tags {
    Name = "${var.team}-${var.environment}"
    Project = "${var.environment}"
    Environment = "${var.environment}"
  }
}

resource "aws_alb_target_group" "concourse-web" {
  name     = "${var.team}-${var.environment}"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  tags {
    Name = "${var.team}-${var.environment}"
    Project = "${var.team}"
    Environment = "${var.environment}"
  }
}

resource "aws_alb_listener" "concourse-web" {
   load_balancer_arn = "${aws_alb.concourse-web.arn}"
   port = "443"
   protocol = "HTTPS"
   ssl_policy = "ELBSecurityPolicy-2015-05"
   certificate_arn = "${var.ssl_certificate_arn}"

   default_action {
     target_group_arn = "${aws_alb_target_group.concourse-web.arn}"
     type = "forward"
   }
}
