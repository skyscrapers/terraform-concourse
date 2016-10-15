resource "aws_cloudwatch_log_group" "adminlogs" {
  name = "${format("%s-%s.admin", var.team, var.role)}"
  retention_in_days = 3
}

resource "aws_cloudwatch_log_group" "workerlogs" {
  name = "${format("%s-%s.worker", var.team, var.role)}"
  retention_in_days = 3
}

resource "aws_ecs_task_definition" "admin" {
  family = "${format("%s-%s-%s", var.team, "concourseadmin", var.environment)}"
  depends_on = ["aws_cloudwatch_log_group.adminlogs"]
  container_definitions = <<EOF
[
  {
    "name": "concourse-admin",
    "essential": true,
    "image": "${format("%s/%s:%s", var.team, "concourse-admin", var.ci_version)}",
    "memory": 512,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${format("%s-%s.admin", var.team, var.role)}",
        "awslogs-region": "${var.region}"
      }
    },
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080,
        "protocol": "tcp"
      },
      {
        "containerPort": 2222,
        "hostPort": 2222,
        "protocol": "tcp"
      }
    ],
    "environment": [
      {"name": "CONCOURSE_DB", "value": "${var.pg_concourse_db}"},
      {"name": "CONCOURSE_DB_HOST", "value": "${var.pg_host}"},
      {"name": "CONCOURSE_DB_PORT", "value": "5432"},
      {"name": "CONCOURSE_DB_USER", "value": "${var.pg_concourse_user}"},
      {"name": "CONCOURSE_DB_PASSWORD", "value": "${var.pg_concourse_password}"},
      {"name": "CONCOURSE_URL", "value": "https://${var.public_hostname}"},
      {"name": "CONCOURSE_GITHUB_CLIENT", "value": "${var.github_app_id}"},
      {"name": "CONCOURSE_GITHUB_SECRET", "value": "${var.github_app_secret}"},
      {"name": "CONCOURSE_GITHUB_ORG", "value": "PewPew-Demonstrations"}
    ]
  }
]
EOF
}

resource "aws_ecs_task_definition" "worker" {
  family = "${format("%s-%s-%s", var.team, "concourseworker", var.environment)}"
  depends_on = ["aws_ecs_task_definition.admin"]
  volume {
    name = "worker-workdir"
    host_path = "/ecs/opt/concourse"
  }
  container_definitions = <<EOF
[
  {
    "name": "concourse-worker",
    "memory": 512,
    "image": "${format("%s/%s:%s", var.team, "concourse-worker", var.ci_version)}",
    "privileged": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${format("%s-%s.worker", var.team, var.role)}",
        "awslogs-region": "${var.region}"
      }
    },
    "environment": [
      {"name": "CONCOURSE_TSA_HOST", "value": "${aws_elb.ssh.dns_name}"}
    ],
    "mountPoints": [
      {
        "sourceVolume": "worker-workdir",
        "containerPath": "/opt/concourse"
      }
    ]
  }
]
EOF
}

resource "aws_ecs_service" "admin" {
  depends_on = ["aws_iam_role.ecs-concourse-role"]
  name = "concourse-admin"
  cluster = "${var.ecs-cluster-arn}"
  task_definition = "${aws_ecs_task_definition.admin.arn}"
  desired_count = "1" // TODO Make this configurable again
  iam_role = "${aws_iam_role.ecs-concourse-role.arn}"
  deployment_minimum_healthy_percent = 0

  load_balancer {
    target_group_arn = "${aws_alb_target_group.concourse-web.arn}"
    container_name = "concourse-admin"
    container_port = 8080
  }

  depends_on = ["aws_iam_policy.concourse"]

}

resource "aws_ecs_service" "worker" {
  depends_on = ["aws_iam_role.ecs-concourse-role"]
  name = "concourse-worker"
  cluster = "${var.ecs-cluster-arn}"
  task_definition = "${aws_ecs_task_definition.worker.arn}"
  desired_count = "1" // TODO Make this configurable again
  #iam_role = "${aws_iam_role.ecs-concourse-role.arn}"
  deployment_minimum_healthy_percent = 0
}
