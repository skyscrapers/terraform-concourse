data "aws_region" "current" {
}

resource "aws_ecs_service" "concourse_web" {
  name            = "concourse_web_${var.name}_${var.environment}"
  cluster         = var.ecs_cluster
  task_definition = aws_ecs_task_definition.concourse_web_task_definition.arn
  desired_count   = var.concourse_web_instance_count
  iam_role        = var.ecs_service_role_arn

  # This will allow the service to be updated even if there's only one instance running in the cluster
  deployment_minimum_healthy_percent = 0

  load_balancer {
    elb_name       = module.elb.elb_name
    container_name = "concourse_web"
    container_port = 8080
  }

  ordered_placement_strategy {
    type  = "spread"
    field = "instanceId"
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_ecs_task_definition" "concourse_web_task_definition" {
  family                = "concourse_web_${var.name}_${var.environment}"
  container_definitions = data.template_file.concourse_web_task_template.rendered
  network_mode          = "bridge"
  task_role_arn         = aws_iam_role.concourse_task_role.arn

  volume {
    name = "concourse_keys"
  }

  volume {
    name = "concourse_db"
  }

  volume {
    name = "concourse_vault"
  }
}

locals {
  concourse_hostname = coalesce(var.concourse_hostname, module.elb.elb_dns_name)
  concourse_version  = coalesce(var.concourse_version_override, var.concourse_version)
}

data "template_file" "concourse_web_task_template" {
  template = file("${path.module}/task-definitions/concourse_web_service.json")

  vars = {
    image                          = "${var.concourse_docker_image}:${local.concourse_version}"
    concourse_hostname             = local.concourse_hostname
    concourse_db_host              = var.concourse_db_host
    concourse_db_port              = var.concourse_db_port
    concourse_db_user              = var.concourse_db_username
    concourse_db_password          = jsonencode(var.concourse_db_password)
    concourse_db_name              = var.concourse_db_name
    awslog_group_name              = aws_cloudwatch_log_group.concourse_web_log_group.name
    awslog_region                  = data.aws_region.current.name
    concourse_keys_bucket_name     = var.keys_bucket_id
    concourse_basic_auth           = var.concourse_auth_username != null && var.concourse_auth_password != null ? data.template_file.concourse_basic_auth.rendered : ""
    concourse_basic_auth_main_team = var.concourse_auth_main_team_local_user != null ?  data.template_file.concourse_basic_auth_main_team_local_user.rendered : ""
    concourse_github_auth          = var.concourse_github_auth_client_id != null && var.concourse_github_auth_client_secret != null && var.concourse_github_auth_team != null ? data.template_file.concourse_github_auth.rendered : ""
    concourse_vault_variables      = var.vault_server_url != null ? data.template_file.concourse_vault_variables.rendered : ""
    memory                         = var.container_memory
    cpu                            = var.container_cpu
    concourse_prometheus_bind_port = var.concourse_prometheus_bind_port
    concourse_prometheus_bind_ip   = var.concourse_prometheus_bind_ip
    concourse_db_task_definition = indent(
      2,
      join("", data.template_file.concourse_db_task_template.*.rendered),
    )
    volumes_from_concourse_db = var.auto_create_db ? ",{ \"sourceContainer\": \"create_db\" }" : ""
    volumes_from_vault_auth   = var.vault_server_url != null ? ",{ \"sourceContainer\": \"vault_auth\" }" : ""
    vault_command_args        = var.vault_server_url != null ? "--vault-client-token=`cat /concourse_vault/token`" : ""
    vault_auth_task_definition = indent(
      2,
      join("", data.template_file.vault_auth_task_template.*.rendered),
    )
  }
}

data "template_file" "concourse_db_task_template" {
  count = var.auto_create_db ? 1 : 0
  template = file(
    "${path.module}/task-definitions/create_concourse_db_container.json",
  )

  vars = {
    image                      = "postgres"
    image_tag                  = coalesce(var.concourse_db_postgres_engine_version, "latest")
    concourse_db_host          = var.concourse_db_host
    concourse_db_port          = var.concourse_db_port
    concourse_db_user          = var.concourse_db_username
    concourse_db_password      = jsonencode(var.concourse_db_password)
    concourse_db_name          = var.concourse_db_name
    concourse_db_root_password = jsonencode(var.concourse_db_root_password)
    awslog_group_name          = aws_cloudwatch_log_group.concourse_web_log_group.name
    awslog_region              = data.aws_region.current.name
  }
}

data "template_file" "vault_auth_task_template" {
  count    = var.vault_server_url !=null ? 1 : 0
  template = file("${path.module}/task-definitions/vault_auth_container.json")

  vars = {
    image             = "vault"
    image_tag         = var.vault_docker_image_tag
    vault_addr        = var.vault_server_url
    auth_header_value = replace(replace(var.vault_server_url, "/^http(s)?:///", ""), "/", "")
    auth_role         = var.vault_auth_concourse_role_name
    awslog_group_name = aws_cloudwatch_log_group.concourse_web_log_group.name
    awslog_region     = data.aws_region.current.name
  }
}

data "template_file" "concourse_vault_variables" {
  template = <<EOF
{ "name": "CONCOURSE_VAULT_URL", "value": "$${concourse_vault_url}" },
EOF


  vars = {
    concourse_vault_url = coalesce(var.vault_server_url, 0)
  }
}

data "template_file" "concourse_basic_auth" {
  template = <<EOF
{ "name": "CONCOURSE_ADD_LOCAL_USER", "value": "$${concourse_auth_username}:$${concourse_auth_password}" },
EOF


vars = {
concourse_auth_username = coalesce(var.concourse_auth_username, 0)
concourse_auth_password = coalesce(var.concourse_auth_password, 0)
}
}

data "template_file" "concourse_basic_auth_main_team_local_user" {
template = <<EOF
{ "name": "CONCOURSE_MAIN_TEAM_LOCAL_USER", "value": "$${concourse_auth_username}" },
EOF


vars = {
concourse_auth_username = coalesce(var.concourse_auth_main_team_local_user, 0)
}
}

data "template_file" "concourse_github_auth" {
template = <<EOF
{ "name": "CONCOURSE_GITHUB_CLIENT_ID", "value": "$${concourse_github_auth_client_id}" },
{ "name": "CONCOURSE_GITHUB_CLIENT_SECRET", "value": "$${concourse_github_auth_client_secret}" },
{ "name": "CONCOURSE_MAIN_TEAM_GITHUB_TEAM", "value": "$${concourse_github_auth_team}" },
EOF


  vars = {
    concourse_github_auth_client_id     = coalesce(var.concourse_github_auth_client_id, 0)
    concourse_github_auth_client_secret = coalesce(var.concourse_github_auth_client_secret, 0)
    concourse_github_auth_team          = coalesce(var.concourse_github_auth_team, 0)
  }
}

resource "aws_cloudwatch_log_group" "concourse_web_log_group" {
  name              = "concourse_web_${var.name}_${var.environment}_logs"
  retention_in_days = "7"

  tags = {
    Name        = var.name
    Environment = var.environment
    Project     = "concourse"
  }
}

resource "aws_cloudwatch_log_metric_filter" "concourse_errors" {
  name           = "ConcourseErrors"
  pattern        = "{ $.log_level > 1 }"
  log_group_name = aws_cloudwatch_log_group.concourse_web_log_group.name

  metric_transformation {
    name          = "ConcourseErrors"
    namespace     = "LogMetrics"
    value         = "1"
    default_value = "0"
  }
}

