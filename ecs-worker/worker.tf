resource "aws_ecs_service" "concourse_worker" {
  name            = "concourse_worker_${var.name}_${var.environment}"
  cluster         = "${var.ecs_cluster}"
  task_definition = "${aws_ecs_task_definition.concourse_worker_task_definition.arn}"
  desired_count   = "${var.concourse_worker_instance_count}"
}

resource "aws_ecs_task_definition" "concourse_worker_task_definition" {
  family                = "concourse_worker_${var.name}_${var.environment}"
  container_definitions = "${data.template_file.concourse_worker_task_template.rendered}"
  network_mode          = "bridge"
  task_role_arn         = "${aws_iam_role.concourse_worker_task_role.arn}"
}

data "template_file" "concourse_worker_task_template" {
  template = "${file("${path.module}/task-definitions/concourse_worker_service.json")}"

  vars {
    image                      = "${var.concourse_docker_image}:${var.concourse_version}"
    awslog_group_name          = "${aws_cloudwatch_log_group.concourse_worker_log_group.name}"
    awslog_region              = "${data.aws_region.current.name}"
    concourse_keys_bucket_name = "${var.keys_bucket_id}"
    concourse_hostname         = "${var.concourse_hostname}"
  }
}

resource "aws_cloudwatch_log_group" "concourse_worker_log_group" {
  name              = "concourse_worker_${var.name}_${var.environment}_logs"
  retention_in_days = "7"

  tags {
    Name        = "${var.name}"
    Environment = "${var.environment}"
    Project     = "concourse"
  }
}
