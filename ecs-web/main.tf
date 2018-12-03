data "aws_region" "current" {}

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

  ordered_placement_strategy {
    type  = "spread"
    field = "instanceId"
  }
}

resource "aws_ecs_task_definition" "concourse_web_task_definition" {
  family                = "concourse_web_${var.name}_${var.environment}"
  container_definitions = "${data.template_file.concourse_web_task_template.rendered}"
  network_mode          = "bridge"
  task_role_arn         = "${aws_iam_role.concourse_task_role.arn}"

  volume {
    name = "concourse_keys"
  }

  volume {
    name = "concourse_db"
  }
}

locals {
  concourse_hostname = "${var.concourse_hostname == "" ? module.elb.elb_dns_name : var.concourse_hostname}"
}

data "template_file" "concourse_web_task_template" {
  template = "${file("${path.module}/task-definitions/concourse_web_service.json")}"

  vars {
    image                          = "${var.concourse_docker_image}:${var.concourse_version}"
    concourse_hostname             = "${local.concourse_hostname}"
    concourse_db_host              = "${var.concourse_db_host}"
    concourse_db_port              = "${var.concourse_db_port}"
    concourse_db_user              = "${var.concourse_db_username}"
    concourse_db_password          = "${var.concourse_db_password}"
    concourse_db_name              = "${var.concourse_db_name}"
    awslog_group_name              = "${aws_cloudwatch_log_group.concourse_web_log_group.name}"
    awslog_region                  = "${data.aws_region.current.name}"
    concourse_keys_bucket_name     = "${var.keys_bucket_id}"
    concourse_basic_auth           = "${length(var.concourse_auth_username) > 0 && length(var.concourse_auth_password) > 0 ? data.template_file.concourse_basic_auth.rendered : ""}"
    concourse_basic_auth_main_team = "${length(var.concourse_auth_main_team_local_user) > 0 ? data.template_file.concourse_basic_auth_main_team_local_user.rendered : ""}"
    concourse_github_auth          = "${length(var.concourse_github_auth_client_id) > 0 && length(var.concourse_github_auth_client_secret) > 0 && length(var.concourse_github_auth_team) > 0 ? data.template_file.concourse_github_auth.rendered : ""}"
    concourse_vault_variables      = "${length(var.vault_server_url) > 0 ? data.template_file.concourse_vault_variables.rendered : ""}"
    memory                         = "${var.container_memory}"
    cpu                            = "${var.container_cpu}"
    concourse_prometheus_bind_port = "${var.concourse_prometheus_bind_port}"
    concourse_prometheus_bind_ip   = "${var.concourse_prometheus_bind_ip}"
    concourse_db_task_definition   = "${indent(2, join("", data.template_file.concourse_db_task_template.*.rendered))}"
    volumes_from_concourse_db      = "${var.auto_create_db ? ",{ \"sourceContainer\": \"create_db\" }" : ""}"
  }
}

data "template_file" "concourse_db_task_template" {
  count    = "${var.auto_create_db ? 1 : 0}"
  template = "${file("${path.module}/task-definitions/create_concourse_db_container.json")}"

  vars {
    image                      = "postgres"
    image_tag                  = "${var.concourse_db_postgres_engine_version == "" ? "latest" : var.concourse_db_postgres_engine_version}"
    concourse_db_host          = "${var.concourse_db_host}"
    concourse_db_port          = "${var.concourse_db_port}"
    concourse_db_user          = "${var.concourse_db_username}"
    concourse_db_password      = "${var.concourse_db_password}"
    concourse_db_name          = "${var.concourse_db_name}"
    concourse_db_root_password = "${var.concourse_db_root_password}"
    awslog_group_name          = "${aws_cloudwatch_log_group.concourse_web_log_group.name}"
    awslog_region              = "${data.aws_region.current.name}"
  }
}

data "template_file" "concourse_vault_variables" {
  template = <<EOF
{ "name": "CONCOURSE_VAULT_URL", "value": "$${concourse_vault_url}" },
{ "name": "CONCOURSE_VAULT_AUTH_BACKEND", "value": "$${concourse_vault_auth_backend}" },
{ "name": "CONCOURSE_VAULT_AUTH_PARAM", "value": "$${concourse_vault_auth_param}" },
{ "name": "CONCOURSE_VAULT_AUTH_BACKEND_MAX_TTL", "value": "$${concourse_vault_auth_backend_max_ttl}" },
EOF

  vars {
    concourse_vault_url                  = "${var.vault_server_url}"
    concourse_vault_auth_backend         = "aws"
    concourse_vault_auth_param           = "header_value=${replace(replace(var.vault_server_url, "/^http(s)?:///", ""), "/", "")},role=${var.vault_auth_concourse_role_name}"
    concourse_vault_auth_backend_max_ttl = "${var.concourse_vault_auth_backend_max_ttl}"
  }
}

data "template_file" "concourse_basic_auth" {
  template = <<EOF
{ "name": "CONCOURSE_ADD_LOCAL_USER", "value": "$${concourse_auth_username}:$${concourse_auth_password}" },
EOF

  vars {
    concourse_auth_username = "${var.concourse_auth_username}"
    concourse_auth_password = "${var.concourse_auth_password}"
  }
}

data "template_file" "concourse_basic_auth_main_team_local_user" {
  template = <<EOF
{ "name": "CONCOURSE_MAIN_TEAM_LOCAL_USER", "value": "$${concourse_auth_username}" },
EOF

  vars {
    concourse_auth_username = "${var.concourse_auth_main_team_local_user}"
  }
}

data "template_file" "concourse_github_auth" {
  template = <<EOF
{ "name": "CONCOURSE_GITHUB_CLIENT_ID", "value": "$${concourse_github_auth_client_id}" },
{ "name": "CONCOURSE_GITHUB_CLIENT_SECRET", "value": "$${concourse_github_auth_client_secret}" },
{ "name": "CONCOURSE_MAIN_TEAM_GITHUB_TEAM", "value": "$${concourse_github_auth_team}" },
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

resource "aws_cloudwatch_log_metric_filter" "concourse_errors" {
  name           = "ConcourseErrors"
  pattern        = "{ $.log_level > 1 }"
  log_group_name = "${aws_cloudwatch_log_group.concourse_web_log_group.name}"

  metric_transformation {
    name          = "ConcourseErrors"
    namespace     = "LogMetrics"
    value         = "1"
    default_value = "0"
  }
}
