terraform {
  required_version = ">= 0.9.0"

  backend "s3" {
    bucket  = "skyscraperstest-terraform"
    key     = "concourse/postgresql"
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

provider "postgresql" {
  alias    = "root"
  host     = "localhost"
  port     = "${module.postgres.rds_port}"
  username = "root"
  password = "concoursetest"
  sslmode  = "require"
}

provider "postgresql" {
  alias    = "concourse"
  host     = "localhost"
  port     = "${module.postgres.rds_port}"
  username = "concourse"
  password = "changeme"
  sslmode  = "require"
}

resource "postgresql_role" "concourse" {
  provider        = "postgresql.root"
  name            = "concourse"
  login           = true
  password        = "changeme"
  create_database = true
}

resource "postgresql_database" "concourse" {
  provider = "postgresql.concourse"
  name     = "concourse"
  owner    = "${postgresql_role.concourse.name}"
}
