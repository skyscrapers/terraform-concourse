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
  task_role_arn         = "arn:aws:iam::847239549153:role/testecstask"                 # TODO: change it
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

resource "aws_s3_bucket" "concourse_keys" {
  bucket = "concourse-keys-${var.environment}"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags {
    Name        = "concourse keys"
    Environment = "${var.environment}"
  }
}

resource "aws_s3_bucket_policy" "concourse_keys" {
  bucket = "${aws_s3_bucket.concourse_keys.bucket}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "PutObjPolicy",
  "Statement": [
    {
      "Sid": "DenyIncorrectEncryptionHeader",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket.concourse_keys.arn}/*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "AES256"
        }
      }
    },
    {
      "Sid": "DenyUnEncryptedObjectUploads",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket.concourse_keys.arn}/*",
      "Condition": {
        "Null": {
          "s3:x-amz-server-side-encryption": "true"
        }
      }
    }
  ]
}
EOF
}
