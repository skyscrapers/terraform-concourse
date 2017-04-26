resource "aws_ecs_service" "concourse_web" {
  name            = "concourse_web_${var.environment}"
  cluster         = "${var.ecs_cluster_arn}"
  task_definition = "${aws_ecs_task_definition.concourse_web_task_definition.arn}"
  desired_count   = "${var.concourse_web_instance_count}"
  iam_role        = "${var.ecs_service_role_arn}"

  load_balancer {
    target_group_arn = "${var.concourse_web_alb_target_group_arn}"
    container_name   = "concourse_web"
    container_port   = 8080
  }

  depends_on = [ "null_resource.generate_concourse_keys" ]
}

resource "aws_ecs_task_definition" "concourse_web_task_definition" {
  family                = "concourse_web_${var.environment}"
  container_definitions = "${data.template_file.concourse_web_task_template.rendered}"
  network_mode          = "bridge"
  task_role_arn         = "${aws_iam_role.concourse_task_role.arn}"
}

data "template_file" "concourse_web_task_template" {
  template = "${file("${path.module}/task-definitions/concourse_web_service.json")}"

  vars {
    image                      = "${var.concourse_docker_image}"
    concourse_auth_username    = "${var.concourse_auth_username}"
    concourse_auth_password    = "${var.concourse_auth_password}"
    concourse_external_url     = "${var.concourse_external_url}"
    concourse_db_uri           = "postgres://${var.concourse_db_username}:${var.concourse_db_password}@${var.concourse_db_host}:${var.concourse_db_port}/${var.concourse_db_name}"
    awslog_group_name          = "${aws_cloudwatch_log_group.concourse_web_log_group.name}"
    awslog_region              = "${data.aws_region.current.name}"
    concourse_keys_bucket_name = "${aws_s3_bucket.concourse_keys.bucket}"
    awslog_worker_group_name   = "${aws_cloudwatch_log_group.concourse_worker_log_group.name}"
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
