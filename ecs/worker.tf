resource "aws_ecs_service" "concourse_worker" {
  name            = "concourse_worker_${var.environment}"
  cluster         = "${var.ecs_cluster_arn}"
  task_definition = "${aws_ecs_task_definition.concourse_worker_task_definition.arn}"
  desired_count   = "${var.concourse_worker_instance_count}"

  depends_on = ["null_resource.generate_concourse_keys"]
}

resource "aws_ecs_task_definition" "concourse_worker_task_definition" {
  family                = "concourse_worker_${var.environment}"
  container_definitions = "${data.template_file.concourse_worker_task_template.rendered}"
  network_mode          = "bridge"
  task_role_arn         = "${aws_iam_role.concourse_task_role.arn}"

  depends_on = ["aws_ecs_task_definition.concourse_web_task_definition"]
}

data "template_file" "concourse_worker_task_template" {
  template = "${file("${path.module}/task-definitions/concourse_worker_service.json")}"

  vars {
    image                      = "${var.concourse_docker_image}"
    awslog_group_name          = "${aws_cloudwatch_log_group.concourse_worker_log_group.name}"
    awslog_region              = "${data.aws_region.current.name}"
    concourse_keys_bucket_name = "${aws_s3_bucket.concourse_keys.bucket}"
    concourse_external_url     = "${var.concourse_external_url}"
  }
}

resource "aws_cloudwatch_log_group" "concourse_worker_log_group" {
  name              = "concourse_worker_logs_${var.environment}"
  retention_in_days = "7"

  tags {
    Environment = "${var.environment}"
    Project     = "concourse"
  }
}
