resource "aws_elb" "web" {
  name = "${var.environment}-admin-web"
  subnets = ["${var.subnets}"]
  security_groups = ["${var.security_groups}"]
  cross_zone_load_balancing = true
  idle_timeout = 300
  connection_draining = true
  connection_draining_timeout = 300

  listener {
    instance_port = 8080
    instance_protocol = "http"
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = "${var.ssl_certificate_arn}"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "TCP:8080"
    interval = 30
  }

  tags {
    Name = "${var.environment}-admin-web"
    EnvID = "${var.environment}"
    Project = "${var.environment}"
    Team = "${var.team}"
    Role = "${var.role}"
    "Application Name" = "ConcourseCI"
    Environment = "${var.environment}"
    Owner = "${var.team}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "ssh" {
  name = "${var.environment}-admin-ssh"
  subnets = ["${var.subnets}"]
  security_groups = ["${var.security_groups}"]
  cross_zone_load_balancing = true
  idle_timeout = 300
  connection_draining = true
  connection_draining_timeout = 300
  internal = true

  listener {
    instance_port = 8080
    instance_protocol = "http"
    lb_port = 8080
    lb_protocol = "http"
  }

  listener {
    instance_port = 2222
    instance_protocol = "tcp"
    lb_port = 2222
    lb_protocol = "tcp"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "TCP:8080"
    interval = 30
  }

  tags {
    Name = "${var.environment}-admin-ssh"
    EnvID = "${var.environment}"
    Project = "${var.environment}"
    Team = "${var.team}"
    Role = "${var.role}"
    "Application Name" = "ConcourseCI"
    Environment = "${var.environment}"
    Owner = "${var.team}"
  }
}

