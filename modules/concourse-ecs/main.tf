resource "aws_ecs_service" "concourse_web" {
  name            = "concourse_web"
  cluster         = "${var.ecs_cluster_arn}"
  task_definition = "${aws_ecs_task_definition.concourse_web_task_definition.arn}"
  desired_count   = 1
  iam_role        = "${var.concourse_web_iam_role_arn}"

  load_balancer {
    target_group_arn = "${var.concourse_web_alb_target_group_arn}"
    container_name   = "concourse_web"
    container_port   = 8080
  }
}

resource "aws_ecs_task_definition" "concourse_web_task_definition" {
  family                = "concourse_web"
  container_definitions = "${data.template_file.concourse_web_task_template.rendered}"
  network_mode          = "bridge"
}

data "template_file" "concourse_web_task_template" {
  template = "${file("${path.module}/task-definitions/concourse_web_service.json")}"

  vars {
    image = "concourse/concourse"
    concourse_db_password = ""
    concourse_external_url = ""
    concourse_db_uri = ""
    awslogs_group = ""
    awslogs_region = ""
  }
}
