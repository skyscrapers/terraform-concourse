resource "aws_alb" "concourse-web" {
  name            = "${var.team}-${var.environment}"
  internal        = false
  security_groups = ["${aws_security_group.alb.id}"]
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

resource "aws_security_group" "alb" {
  name = "${var.team}-${var.environment}-alb"
  vpc_id = "${var.vpc_id}"
  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}
