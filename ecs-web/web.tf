resource "aws_ecs_service" "concourse_web" {
  name            = "concourse_web_${var.name}_${var.environment}"
  cluster         = "${var.ecs_cluster}"
  task_definition = "${aws_ecs_task_definition.concourse_web_task_definition.arn}"
  desired_count   = "${var.concourse_web_instance_count}"
  iam_role        = "${var.ecs_service_role_arn}"

  load_balancer {
    elb_name       = "${module.elb.elb_name}"
    container_name = "concourse_web"
    container_port = 8080
  }

  placement_strategy {
    type  = "spread"
    field = "instanceId"
  }
}

resource "aws_ecs_task_definition" "concourse_web_task_definition" {
  family                = "concourse_web_${var.name}_${var.environment}"
  container_definitions = "${data.template_file.concourse_web_task_template.rendered}"
  network_mode          = "bridge"
  task_role_arn         = "${aws_iam_role.concourse_task_role.arn}"
}

data "template_file" "concourse_web_task_template" {
  template = "${file("${path.module}/task-definitions/concourse_web_service.json")}"

  vars {
    image                      = "${var.concourse_docker_image}:${var.concourse_version}"
    concourse_hostname         = "${var.concourse_hostname}"
    concourse_db_uri           = "postgres://${var.concourse_db_username}:${var.concourse_db_password}@${var.concourse_db_host}:${var.concourse_db_port}/${var.concourse_db_name}"
    awslog_group_name          = "${aws_cloudwatch_log_group.concourse_web_log_group.name}"
    awslog_region              = "${data.aws_region.current.name}"
    concourse_keys_bucket_name = "${var.keys_bucket_id}"
    concourse_basic_auth       = "${length(var.concourse_auth_username) > 0 && length(var.concourse_auth_password) > 0 ? data.template_file.concourse_basic_auth.rendered : ""}"
    concourse_github_auth      = "${length(var.concourse_github_auth_client_id) > 0 && length(var.concourse_github_auth_client_secret) > 0 && length(var.concourse_github_auth_team) > 0 ? data.template_file.concourse_github_auth.rendered : ""}"
    concourse_vault_variables  = "${length(var.vault_server_url) > 0 ? data.template_file.concourse_vault_variables.rendered : ""}"
    memory                     = "${var.container_memory}"
    cpu                        = "${var.container_cpu}"
  }
}

data "template_file" "concourse_vault_variables" {
  template = <<EOF
{ "name": "CONCOURSE_VAULT_URL", "value": "$${concourse_vault_url}" },
{ "name": "CONCOURSE_VAULT_AUTH_BACKEND", "value": "$${concourse_vault_auth_backend}" },
{ "name": "CONCOURSE_VAULT_AUTH_PARAM", "value": "$${concourse_vault_auth_param}" },
EOF

  vars {
    concourse_vault_url          = "${var.vault_server_url}"
    concourse_vault_auth_backend = "aws"
    concourse_vault_auth_param   = "header_value=${replace(replace(var.vault_server_url, "/^http(s)?:///", ""), "/", "")},role=${var.vault_auth_concourse_role_name}"
  }
}

data "template_file" "concourse_basic_auth" {
  template = <<EOF
{ "name": "CONCOURSE_BASIC_AUTH_USERNAME", "value": "$${concourse_auth_username}" },
{ "name": "CONCOURSE_BASIC_AUTH_PASSWORD", "value": "$${concourse_auth_password}" },
EOF

  vars {
    concourse_auth_username = "${var.concourse_auth_username}"
    concourse_auth_password = "${var.concourse_auth_password}"
  }
}

data "template_file" "concourse_github_auth" {
  template = <<EOF
{ "name": "CONCOURSE_GITHUB_AUTH_CLIENT_ID", "value": "$${concourse_github_auth_client_id}" },
{ "name": "CONCOURSE_GITHUB_AUTH_CLIENT_SECRET", "value": "$${concourse_github_auth_client_secret}" },
{ "name": "CONCOURSE_GITHUB_AUTH_TEAM", "value": "$${concourse_github_auth_team}" },
EOF

  vars {
    concourse_github_auth_client_id     = "${var.concourse_github_auth_client_id}"
    concourse_github_auth_client_secret = "${var.concourse_github_auth_client_secret}"
    concourse_github_auth_team          = "${var.concourse_github_auth_team}"
  }
}

resource "aws_cloudwatch_log_group" "concourse_web_log_group" {
  name              = "concourse_web_${var.name}_${var.environment}_logs"
  retention_in_days = "7"

  tags {
    Name        = "${var.name}"
    Environment = "${var.environment}"
    Project     = "concourse"
  }
}
