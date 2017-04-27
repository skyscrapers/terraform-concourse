terraform {
  required_version = ">= 0.9.0"

  backend "s3" {
    bucket  = "skyscraperstest-terraform"
    key     = "concourse/concourse"
    region  = "eu-west-1"
    encrypt = true
  }
}

provider "aws" {
  region = "${var.aws_region}"
}

data "terraform_remote_state" "static" {
  backend     = "s3"
  environment = "${terraform.env}"

  config {
    bucket = "skyscraperstest-terraform"
    key    = "concourse/main"
    region = "eu-west-1"
  }
}

data "aws_kms_secret" "concourse_github_auth_client_secret" {
  secret {
    name    = "github_auth_client_secret"
    payload = "${var.concourse_github_auth_client_secret_encrypted["${terraform.env}"]}"

    context {
      concourse = "gh_client_secret"
    }
  }
}

module "concourse" {
  source                              = "../../ecs"
  environment                         = "${terraform.env}"
  ecs_cluster                         = "${data.terraform_remote_state.static.ecs_cluster_name}"
  concourse_db_host                   = "${data.terraform_remote_state.static.rds_address}"
  ecs_service_role_arn                = "${data.terraform_remote_state.static.ecs-service-role}"
  concourse_hostname                  = "${var.concourse_hostname["${terraform.env}"]}"
  concourse_db_username               = "${var.concourse_db_username["${terraform.env}"]}"
  concourse_db_password               = "${var.concourse_db_password["${terraform.env}"]}"
  concourse_db_name                   = "${var.concourse_db_name["${terraform.env}"]}"
  concourse_github_auth_client_id     = "${var.concourse_github_auth_client_id["${terraform.env}"]}"
  concourse_github_auth_client_secret = "${data.aws_kms_secret.concourse_github_auth_client_secret.github_auth_client_secret}"
  concourse_github_auth_team          = "${var.concourse_github_auth_team["${terraform.env}"]}"
  elb_subnets                         = "${data.terraform_remote_state.static.public_lb_subnets}"
  backend_security_group_id           = "${data.terraform_remote_state.static.sg_ecs_instance}"
  ssl_certificate_id                  = "${var.elb_ssl_certificate["${terraform.env}"]}"
}