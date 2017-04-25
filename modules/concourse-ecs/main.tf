data "aws_region" "current" {
  current = true
}

resource "aws_ecs_service" "concourse_web" {
  name            = "concourse_web_${var.environment}"
  cluster         = "${var.ecs_cluster_arn}"
  task_definition = "${aws_ecs_task_definition.concourse_web_task_definition.arn}"
  desired_count   = 1
  iam_role        = "${var.ecs_service_role_arn}"

  load_balancer {
    target_group_arn = "${var.concourse_web_alb_target_group_arn}"
    container_name   = "concourse_web"
    container_port   = 8080
  }
}

resource "aws_ecs_task_definition" "concourse_web_task_definition" {
  family                = "concourse_web_${var.environment}"
  container_definitions = "${data.template_file.concourse_web_task_template.rendered}"
  network_mode          = "bridge"
}

data "template_file" "concourse_web_task_template" {
  template = "${file("${path.module}/task-definitions/concourse_web_service.json")}"

  vars {
    image                   = "${var.concourse_docker_image}"
    concourse_auth_username = "concourse"
    concourse_auth_password = "changeme"
    concourse_external_url  = "${var.concourse_external_url}"
    concourse_db_uri        = "postgres://${var.concourse_db_username}:${var.concourse_db_password}@${var.concourse_db_host}:${var.concourse_db_port}/concourse?sslmode=disable"
    awslog_group_name       = "${aws_cloudwatch_log_group.concourse_web_log_group.name}"
    awslog_region           = "${data.aws_region.current.name}"
  }
}

resource "aws_cloudwatch_log_group" "concourse_web_log_group" {
  name              = "concourse_web_logs_${var.environment}"
  retention_in_days = "7"

  tags {
    Environment = "${var.environment}"
    Project     = "concourse"
  }
}
